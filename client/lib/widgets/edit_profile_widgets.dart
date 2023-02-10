import 'dart:io';

import 'package:client/models/baby_profile.dart';
import 'package:client/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileWidgets {
  static Widget name(TextEditingController nameController, bool autofocus) {
    return Padding(
      padding: const EdgeInsets.only(right: 48),
      child: TextFormField(
        autofocus: autofocus,
        controller: nameController,
        validator: (value) {
          return (value == null || value.isEmpty) ? '' : null;
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.edit),
          labelText: 'Baby\'s Full Name',
          errorStyle: TextStyle(height: 0),
        ),
      ),
    );
  }

  static _selectDate(
      TextEditingController birthDateController, BuildContext context) async {
    DateTime initialDate;

    if (birthDateController.text.isNotEmpty) {
      initialDate = DateTime.parse(birthDateController.text);
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null &&
        selectedDate.toString() != birthDateController.text) {
      birthDateController.text = selectedDate.toString();
    }
  }

  static String _getFormattedDate(TextEditingController birthDateController) {
    if (birthDateController.text.isNotEmpty) {
      DateTime unformattedDate = DateTime.parse(birthDateController.text);
      return '${unformattedDate.month}/${unformattedDate.day}/${unformattedDate.year}';
    }

    return '';
  }

  static Widget birthDate(
      BuildContext context, TextEditingController birthDateController) {
    final viewController = TextEditingController();
    viewController.text = _getFormattedDate(birthDateController);

    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: (viewController.text.isEmpty) ? 168 : 120,
          child: TextFormField(
            controller: viewController,
            readOnly: true,
            validator: (value) {
              return (value == null ||
                      value.isEmpty ||
                      value == 'Select Date of Birth')
                  ? 'Select Baby\'s Date of birth'
                  : null;
            },
            decoration: const InputDecoration(
              hintText: 'Baby\'s Date of Birth',
              icon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              await _selectDate(birthDateController, context);
              setState(() =>
                  viewController.text = _getFormattedDate(birthDateController));
            },
          ),
        );
      },
    );
  }

  static Widget gender(
      BuildContext context, TextEditingController genderController) {
    var items = ['Male', 'Female', 'Other'];

    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: 120,
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            icon: Icon(BabyProfile.getGenderIcon(
              int.tryParse(genderController.text) ?? 3,
            )),
            contentPadding: EdgeInsets.zero,
            label: const Text('Gender'),
          ),
          value: (int.tryParse(genderController.text) != null)
              ? items[int.parse(genderController.text)]
              : null,
          style: Theme.of(context).textTheme.subtitle1,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black45,
          ),
          items: items.map((String items) {
            return DropdownMenuItem(value: items, child: Text(items));
          }).toList(),
          onChanged: (newValue) {
            setState(() => genderController.text =
                items.indexOf(newValue.toString()).toString());
          },
          validator: (value) {
            return (value == null) ? 'Select Baby\'s Gender' : null;
          },
        ),
      );
    });
  }

  static Widget height(TextEditingController heightController) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: TextFormField(
            autofocus: true,
            keyboardType: TextInputType.number,
            controller: heightController,
            validator: (value) {
              return (value == null || value.isEmpty) ? '' : null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.straighten),
              hintText: '24',
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
        const Text('in'),
      ],
    );
  }

  static Widget weight(TextEditingController weightLbController,
      TextEditingController weightOzController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: TextFormField(
            autofocus: true,
            keyboardType: TextInputType.number,
            controller: weightLbController,
            validator: (value) {
              return (value == null || value.isEmpty) ? '' : null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.monitor_weight_outlined),
              hintText: '12',
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Text('lbs'),
        ),
        SizedBox(
          width: 80,
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: weightOzController,
            validator: (value) {
              return (value == null || value.isEmpty) ? '' : null;
            },
            decoration: const InputDecoration(
              icon: Icon(
                Icons.monitor_weight_outlined,
                color: Colors.transparent,
              ),
              hintText: '3',
              contentPadding: EdgeInsets.only(bottom: 6),
            ),
          ),
        ),
        const Text('oz'),
      ],
    );
  }

  static Widget _allergyField(int index, List<String> allergyNames,
      List<int> allergySeverities, List<int> remove, Function setState) {
    var items = ['Mild', 'Moderate', 'Severe'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
              initialValue: allergyNames[index],
              decoration: InputDecoration(
                  icon: const Icon(Icons.warning_amber_outlined),
                  labelText: 'Allergy ${index + 1}',
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 6)),
              onChanged: (newValue) {
                allergyNames[index] = newValue.toString();
              },
              validator: (value) {
                if ((value == null || value.isEmpty) &&
                    allergySeverities[index] == -1) {
                  remove.add(index);
                  return null;
                }
                return (value == null || value.isEmpty)
                    ? 'Enter Allergy or Delete'
                    : null;
              }),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 13),
          child: SizedBox(
            width: 88,
            child: DropdownButtonFormField(
                hint: const Text('Severity'),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 2)),
                value: (allergySeverities[index] != -1)
                    ? items[allergySeverities[index]]
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(value: items, child: Text(items));
                }).toList(),
                onChanged: (newValue) {
                  allergySeverities[index] = items.indexOf(newValue.toString());
                },
                validator: (value) {
                  return (value != null || remove.contains(index))
                      ? null
                      : 'Select Severity';
                }),
          ),
        ),
        IconButton(
          iconSize: 16,
          padding: const EdgeInsets.only(top: 12),
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              allergyNames.removeAt(index);
              allergySeverities.removeAt(index);
            });
          },
        ),
      ],
    );
  }

  static Widget allergies(List<String> allergyNames,
      List<int> allergySeverities, List<int> remove) {
    return StatefulBuilder(
      builder: (context, setState) {
        List<Widget> allergyFields =
            List.generate(allergyNames.length, (int index) {
          return _allergyField(
              index, allergyNames, allergySeverities, remove, setState);
        });

        allergyFields.add(
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  allergyNames.add('');
                  allergySeverities.add(-1);
                });
              },
              splashColor: Theme.of(context).colorScheme.secondary,
              child: Padding(
                padding: const EdgeInsets.only(left: 32, top: 16),
                child: Text(
                  'Add Allergy',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
        );

        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: allergyFields);
      },
    );
  }

  static Widget pediatrician(TextEditingController pedController) {
    return Padding(
      padding: const EdgeInsets.only(right: 48),
      child: TextFormField(
        autofocus: true,
        controller: pedController,
        validator: (value) {
          return (value == null || value.isEmpty) ? '' : null;
        },
        decoration: const InputDecoration(
            icon: Icon(Icons.medical_services_outlined),
            labelText: 'Name of Pediatrician'),
      ),
    );
  }

  static Widget pediatricianPhone(TextEditingController pedPhoneController) {
    return Padding(
      padding: const EdgeInsets.only(right: 48),
      child: TextFormField(
        autofocus: true,
        keyboardType: TextInputType.phone,
        controller: pedPhoneController,
        validator: (value) {
          return (value == null || value.length != 12) ? '' : null;
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.contacts_outlined),
          labelText: 'Pediatrician\'s Phone Number',
        ),
        inputFormatters: [
          LibPhonenumberTextFormatter(
            country: const CountryWithPhoneCode.us(),
            inputContainsCountryCode: false,
            additionalDigits: 0,
          ),
        ],
      ),
    );
  }

  static List<Widget> _getImage(TextEditingController imageController) {
    if (imageController.text.isEmpty) return [];

    File imageFile = File(imageController.text);
    if (imageFile.existsSync()) {
      return [Image.file(File(imageController.text))];
    }

    return [Image.network(imageController.text)];
  }

  static Future _pickImage(
      TextEditingController imageController, Function setState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => imageController.text = pickedFile.path);
    }
  }

  static Widget profilePicture(TextEditingController imageController) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            ..._getImage(imageController),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () => _pickImage(imageController, setState),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Profile Picture',
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _sharedUser(
      String uid,
      String email,
      Map<String, String> newUsers,
      List<String> removedUsers,
      Function setState) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: email,
            decoration: const InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.person),
              enabled: false,
              isDense: false,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (newUsers.containsKey(uid)) {
              setState(() => newUsers.remove(uid));
            } else {
              setState(() => removedUsers.add(uid));
            }
          },
        ),
      ],
    );
  }

  static List<Widget> _sharedUsers(
      Map<String, String> currentUsers,
      Map<String, String> newUsers,
      List<String> removedUsers,
      Function setState) {
    List<Widget> sharedUserWidgets = [];

    newUsers.forEach((uid, name) {
      sharedUserWidgets
          .add(_sharedUser(uid, name, newUsers, removedUsers, setState));
    });

    currentUsers.forEach((uid, name) {
      if (!removedUsers.contains(uid)) {
        sharedUserWidgets
            .add(_sharedUser(uid, name, newUsers, removedUsers, setState));
      }
    });

    return sharedUserWidgets;
  }

  static Future shareProfile(String profileId, String currentUserEmail,
      Map<String, String> newUsers, List<String> removedUsers) async {
    Map<String, String> currentUsers =
        await DataService.getProfileSharedUsers(profileId);

    final newUserEmail = TextEditingController();

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newUserEmail,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person_add),
                    labelText: 'User Email',
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              TextButton(
                child: Text(
                  'Add User',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                onPressed: () async {
                  if (currentUsers.containsValue(newUserEmail.text)) {
                    debugPrint('Specified user is already added');
                    return;
                  } else if (newUserEmail.text == currentUserEmail) {
                    debugPrint('You cannot add yourself');
                    return;
                  }

                  final uid =
                      await DataService.getUserFromEmail(newUserEmail.text);

                  if (uid != null) {
                    setState(() => newUsers[uid] = newUserEmail.text);
                  } else {
                    debugPrint('Specified user doesn\'t exist');
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ..._sharedUsers(currentUsers, newUsers, removedUsers, setState),
        ],
      );
    });
  }

  static Widget editNotes(TextEditingController notes) {
    return TextFormField(
      autofocus: true,
      maxLines: 3,
      controller: notes,
      decoration: const InputDecoration(
        labelText: 'Notes',
        icon: Icon(Icons.sticky_note_2),
        errorStyle: TextStyle(height: 0),
      ),
    );
  }
}
