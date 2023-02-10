import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import 'package:client/models/day_stats.dart';
import 'package:client/services/data_service.dart';

class BabyProfile {
  static BabyProfile defaultProfile = BabyProfile('');
  static BabyProfile? _currentProfile;

  // private properties
  DateTime? _created;

  String? _name;
  int? _gender;
  double? _height;
  double? _weightLb;
  double? _weightOz;
  DateTime? _birthDate;
  Map<String, int>? _allergies;

  String? _pediatrician;
  String? _pediatricianPhone;
  String? _formattedPedPhone;

  String? _profilePic;

  DateTime? _startedSleep;

  Map<DateTime, List<DateTime>>? _diaperChanges;
  Map<DateTime, List<DateTime>>? _feedings;
  Map<DateTime, Map<DateTime, DateTime>>? _sleep;
  Map<DateTime, String>? _notes;

  // public properties
  final String uid;

  // babyProfile update stream
  static final _streamController = StreamController.broadcast();
  static final updateStream = _streamController.stream;

  // static accessors
  static BabyProfile get currentProfile => _currentProfile ?? defaultProfile;

  static set currentProfile(BabyProfile? profile) {
    if (profile == currentProfile) return;
    if (currentProfile.exists) currentProfile._removeDataSync();
    if (profile != null) profile._setDataSync();

    _currentProfile = profile;
  }

  // public accessors
  bool get exists => uid.isNotEmpty;

  DateTime get created => _created ?? DateTime.now();
  String get name => _name ?? '';

  int get genderRaw => _gender ?? 0;
  IconData get genderIcon => getGenderIcon(_gender ?? 0);
  String get gender {
    switch (_gender) {
      case 0:
        return "Male";
      case 1:
        return "Female";
      default:
        return "Other";
    }
  }

  double get heightIn => _height ?? 0;
  String get height => '${heightIn.toInt().toString()}"';

  double get weightLb => _weightLb ?? 0;
  double get weightOz => _weightOz ?? 0;
  String get weight =>
      '${weightLb.toInt().toString()}lbs ${weightOz.toInt().toString()}oz';

  DateTime? get birthDate => _birthDate;
  String get age {
    if (birthDate == null) return '';
    int days = DateTime.now().difference(birthDate!).inDays;

    if (days < 7) {
      return days.toString() + (days == 1 ? ' day' : ' days');
    } else if (days < 30.44) {
      int weeks = (days ~/ 7);
      return weeks.toString() + (weeks == 1 ? ' week' : ' weeks');
    } else if (days < 365.25) {
      int months = (days ~/ 30.44);
      return months.toString() + (months == 1 ? ' month' : ' months');
    } else {
      int years = (days ~/ 365.25);
      return years.toString() + (years == 1 ? ' year' : ' years');
    }
  }

  Map<String, int> get allergies => _allergies ?? {};

  String get pediatrician => _pediatrician ?? '';
  String get pediatricianPhone => _pediatricianPhone ?? '';
  String get formattedPedPhone {
    return _formattedPedPhone ?? '';
  }

  String get profilePic => _profilePic ?? '';
  DateTime? get startedSleep => _startedSleep;

  BabyProfile(this.uid);

  // private methods
  void _setDataSync() async => DataService.setProfileDataSync(uid, _setData);
  void _removeDataSync() async => DataService.removeProfileDataSync(uid);

  Future _setData(Map<String, dynamic> profileData) async {
    _created = DateTime.parse(profileData['created'] as String);

    _name = profileData['name'] as String;
    _gender = profileData['gender'] as int;
    _height = profileData['height'] as double;
    _weightLb = profileData['weightLb'] as double;
    _weightOz = profileData['weightOz'] as double;
    _birthDate = DateTime.parse(profileData['birth_date'] as String);
    _allergies =
        (profileData['allergies'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, value as int);
    });

    _pediatrician = profileData['pediatrician'];
    _pediatricianPhone = profileData['pediatrician_phone'];
    _formattedPedPhone = (await FlutterLibphonenumber()
        .format(pediatricianPhone, 'US'))['formatted'];

    _profilePic = profileData['profile_pic'] as String;

    if (profileData['started_sleep'] != null) {
      _startedSleep = DateTime.parse(profileData['started_sleep'] as String);
    }

    _diaperChanges = (profileData['diaper_changes'] as Map<String, dynamic>)
        .map((key, value) {
      return MapEntry(
          DateTime.parse(key),
          (value as List)
              .map((item) => DateTime.parse(item as String))
              .toList());
    });

    _feedings =
        (profileData['feedings'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(
          DateTime.parse(key),
          (value as List)
              .map((item) => DateTime.parse(item as String))
              .toList());
    });

    _sleep = (profileData['sleep'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(
          DateTime.parse(key),
          (value as Map<String, dynamic>).map((key, value) {
            return MapEntry(
                DateTime.parse(key), DateTime.parse(value as String));
          }));
    });

    _notes = (profileData['notes'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(DateTime.parse(key), value as String);
    });

    _streamController.add(currentProfile);
  }

  static IconData getGenderIcon(int genderRaw) {
    switch (genderRaw) {
      case 0:
        return Icons.male;
      case 1:
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }

  DayStats getDayStats(DateTime date) {
    return DayStats(
      date: date,
      diaperChanges: _diaperChanges?[date] ?? [],
      feedings: _feedings?[date] ?? [],
      sleep: _sleep?[date] ?? {},
      notes: _notes?[date] ?? '',
    );
  }

  void updateData(Map<String, dynamic> data) {
    DataService.updateProfileData(uid, data);
  }

  void incrementDiaperChanges(DateTime time) {
    DateTime day = DateTime(time.year, time.month, time.day);

    _diaperChanges ??= {};
    _diaperChanges![day] ??= [];
    _diaperChanges![day]!.add(time);

    final databaseMap = _diaperChanges!.map((key, value) {
      return MapEntry(
          key.toString(), value.map((time) => time.toString()).toList());
    });

    updateData({'diaper_changes': databaseMap});
  }

  void removeLastDiaperChange() {
    DateTime now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day);

    _diaperChanges ??= {};
    _diaperChanges![day] ??= [];

    if (_diaperChanges![day]!.isNotEmpty) _diaperChanges![day]!.removeLast();

    final databaseMap = _diaperChanges!.map((key, value) {
      return MapEntry(
          key.toString(), value.map((time) => time.toString()).toList());
    });

    updateData({'diaper_changes': databaseMap});
  }

  void incrementFeedings(DateTime time) {
    DateTime day = DateTime(time.year, time.month, time.day);

    _feedings ??= {};
    _feedings![day] ??= [];
    _feedings![day]!.add(time);

    final databaseMap = _feedings!.map((key, value) {
      return MapEntry(
          key.toString(), value.map((time) => time.toString()).toList());
    });

    updateData({'feedings': databaseMap});
  }

  void removeLastFeeding() {
    DateTime now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day);

    _feedings ??= {};
    _feedings![day] ??= [];

    if (_feedings![day]!.isNotEmpty) _feedings![day]!.removeLast();

    final databaseMap = _feedings!.map((key, value) {
      return MapEntry(
          key.toString(), value.map((time) => time.toString()).toList());
    });

    updateData({'feedings': databaseMap});
  }

  void trackSleep(DateTime time) {
    if (_startedSleep == null) {
      _startedSleep = time;
      updateData({'started_sleep': time.toString()});
    } else {
      DateTime day = DateTime(time.year, time.month, time.day);
      DateTime started = _startedSleep ?? DateTime.now();

      _sleep ??= {};
      _sleep![day] ??= {};
      _sleep![day]![started] = time;
      _startedSleep = null;

      final databaseMap = _sleep!.map((key, value) {
        return MapEntry(key.toString(), value.map((key, value) {
          return MapEntry(key.toString(), value.toString());
        }));
      });

      updateData({'started_sleep': null, 'sleep': databaseMap});
    }
  }

  void updateProfileImage(String imagePath) async {
    String imageUrl = await DataService.uploadProfileImage(uid, File(imagePath),
        currentImageUrl: _profilePic);
    updateData({'profile_pic': imageUrl});
  }

  void updatePermissions(
      Map<String, String> newUsers, List<String> removedUsers) {
    for (var userId in newUsers.keys) {
      DataService.updateUserPermissions(userId, add: uid);
    }

    for (var userId in removedUsers) {
      DataService.updateUserPermissions(userId, remove: uid);
    }
  }

  void updateNotes(DateTime day, String notes) {
    _notes ??= {};
    _notes![DateTime(day.year, day.month, day.day)] = notes;

    final newNotes = _notes!.map((key, value) {
      return MapEntry(key.toString(), value);
    });

    updateData({'notes': newNotes});
  }
}
