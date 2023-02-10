import 'package:auto_size_text/auto_size_text.dart';
import 'package:client/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:client/models/baby_profile.dart';
import 'package:client/models/day_stats.dart';
import 'package:client/widgets/dotted_divider.dart';
import 'package:client/widgets/round_button.dart';
import 'package:client/services/data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BabyProfile currentBby = BabyProfile.currentProfile;

  String _qodMessage = '';
  String _qodAuthor = '';
  bool _demoQOD = false;

  bool _isSleeping = false;
  int _feedingCount = 0;
  int _diaperCount = 0;

  int _sleepDays = 0;
  int _sleepHours = 0;
  int _sleepMins = 0;

  SnackBar _getSnackBar({required String text, VoidCallback? onPressed}) {
    return SnackBar(
      padding: (onPressed != null)
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1000),
      content: Text(text),
      action: (onPressed != null)
          ? SnackBarAction(
              label: 'Undo',
              onPressed: onPressed,
            )
          : null,
    );
  }

  //Builds the message. Only shows 2 units of time (Days, Minutes, Seconds)
  String _getSleepMessage() {
    String sleepMessage = '';
    int unitCount = 0;

    if (_sleepDays > 0) {
      sleepMessage += '${_sleepDays}d';
      unitCount++;
    }
    if (_sleepHours > 0) {
      if (sleepMessage.isNotEmpty) {
        sleepMessage += ' and ';
      }
      sleepMessage += '${_sleepHours}h';
      unitCount++;
    }
    if (_sleepMins >= 0 && unitCount < 2) {
      if (sleepMessage.isNotEmpty) {
        sleepMessage += ' and ';
      }
      sleepMessage += '${_sleepMins}m';
      unitCount++;
    }
    sleepMessage += ' of Sleep';
    return 'Recorded ' + sleepMessage;
  }

  void _showSleepStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1250),
        content: Text(_isSleeping ? 'Starting Sleep...' : _getSleepMessage()),
      ),
    );
  }

  void _recordFeeding() {
    currentBby.incrementFeedings(DateTime.now());
    _feedingCount += 1;
    ScaffoldMessenger.of(context).showSnackBar(
      _getSnackBar(
        text: _feedingCount > 1
            ? '$_feedingCount Feedings Recorded'
            : '$_feedingCount Feeding Recorded',
        onPressed: currentBby.removeLastFeeding,
      ),
    );
  }

  void _recordDiaper() {
    currentBby.incrementDiaperChanges(DateTime.now());
    _diaperCount += 1;
    ScaffoldMessenger.of(context).showSnackBar(
      _getSnackBar(
        text: _diaperCount > 1
            ? '$_diaperCount Diaper Changes Recorded'
            : '$_diaperCount Diaper Change Recorded',
        onPressed: currentBby.removeLastDiaperChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var quoteGroup = AutoSizeGroup();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: BabyProfile.updateStream,
        builder: (context, snapshot) {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          DayStats stats = currentBby.getDayStats(today);
          _isSleeping = currentBby.startedSleep != null;
          _diaperCount = stats.diaperChanges.length;
          _feedingCount = stats.feedings.length;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  colorFilter:
                      ColorFilter.mode(Color(0x25FFFFFF), BlendMode.dstATop),
                  image: AssetImage('assets/images/undraw_baby.png'),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 16),
                          child: Text(
                            'Welcome Back ${AppUser.currentUser?.name ?? 'Parent'}!',
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const DottedDivider(),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: InkWell(
                              splashColor:
                                  Theme.of(context).colorScheme.primary,
                              onTap: () {},
                              onLongPress: () {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: '$_qodMessage - $_qodAuthor'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _getSnackBar(
                                    text: 'Quote Copied To Clipboard',
                                  ),
                                );
                              },
                              child: FutureBuilder(
                                future: _setup(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: AutoSizeText(
                                            _qodMessage,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2,
                                            group: quoteGroup,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AutoSizeText(
                                            '- ' + _qodAuthor,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                            group: quoteGroup,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const DottedDivider(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 32, right: 32, bottom: 48, top: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RoundButton(
                          backgroundColor: _isSleeping
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          textColor: _isSleeping
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondary,
                          text: _isSleeping ? 'Stop Sleep' : 'Start Sleep',
                          onPressed: () {
                            DateTime now = DateTime.now();
                            if (_isSleeping) {
                              _sleepDays = now
                                  .difference(currentBby.startedSleep!)
                                  .inDays;
                              _sleepHours = now
                                  .difference(currentBby.startedSleep!)
                                  .inHours;
                              _sleepMins = now
                                  .difference(currentBby.startedSleep!)
                                  .inMinutes;
                            }

                            currentBby.trackSleep(now);
                            _isSleeping = !_isSleeping;
                            _showSleepStatus();
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        RoundButton(
                          text: 'Record Feeding  |  $_feedingCount',
                          onPressed: _recordFeeding,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        RoundButton(
                          text: 'Record Diaper Change  |  $_diaperCount',
                          onPressed: _recordDiaper,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _setup() async {
    if (_demoQOD) {
      _qodMessage = 'Behind every young child who believes in himself is a parent who believed first.';
      _qodAuthor = 'Matthew Jacobsen';

      return true;
    }
    List<String> qodData = await DataService.getQOD();
    _qodMessage = qodData[1];
    _qodAuthor = qodData[2];

    return true;
  }
}
