import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static final _database = FirebaseFirestore.instance;
  static final _userCollection = _database.collection('users');
  static final _profileCollection = _database.collection('profiles');

  static final _storage = FirebaseStorage.instance;
  static final _profilePics = _storage.ref('profile_pics');

  static dynamic _userListener;
  static dynamic _profileListener;

  // default UserData
  static const _defaultUserData = {
    'profiles': [],
    'shared_profiles': [],
    'to_do_list': {},
    'notes': {},
  };

  static getProfileSharedUsers(String profileId) async {
    Map<String, String> sharedUsers = {};

    await _userCollection
        .where('shared_profiles', arrayContains: profileId)
        .get()
        .then((query) {
      for (var document in query.docs) {
        final data = document.data();
        sharedUsers[document.id] = data['email'] as String;
      }
    });

    return sharedUsers;
  }

  static getUserFromEmail(String email) async {
    String? uid;

    await _userCollection.where('email', isEqualTo: email).get().then((query) {
      if (query.docs.isNotEmpty) {
        uid = query.docs[0].id;
      }
    });

    return uid;
  }

  static updateUserPermissions(String uid,
      {String? add, String? remove}) async {
    DocumentReference userDocument = _userCollection.doc(uid);
    List<String> sharedProfiles = [];

    await userDocument.get().then((document) {
      final data = document.data() as Map<String, dynamic>;
      sharedProfiles = (data['shared_profiles'] as List)
          .map((item) => item as String)
          .toList();
    });

    if (add != null) {
      sharedProfiles.add(add);
    }

    if (remove != null) {
      sharedProfiles.remove(remove);
    }

    updateUserData(uid, {'shared_profiles': sharedProfiles});
  }

  static updateUserData(String uid, Map<String, dynamic> fields) async {
    DocumentReference userDocument = _userCollection.doc(uid);
    await userDocument.update(fields);
  }

  // sets data sync for user data with database
  static setUserDataSync(
      String uid, String name, String email, Function update) async {
    DocumentReference userDocument = _userCollection.doc(uid);

    // If user data doesn't exist yet, create it
    await userDocument.get().then((document) {
      if (!document.exists) {
        Map<String, dynamic> userData = Map.of(_defaultUserData);
        userData['name'] = name;
        userData['email'] = email;
        userDocument.set(userData);
      }
    });

    _userListener = userDocument.snapshots().listen((document) {
      update(document.data() as Map<String, dynamic>);
    });
  }

  // removes data sync for user data with database
  static removeUserDataSync(String uid) {
    if (_userListener != null) {
      _userListener.cancel();
    }

    if (_userListener == null) return;

    _userListener.cancel();
    _userListener = null;
  }

  static Future uploadProfileImage(String uid, File imageFile,
      {String? currentImageUrl}) async {
    String imageUrl = '';

    if (currentImageUrl != null) {
      try {
        await _profilePics.child(imageUrl).delete();
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    Reference imageRef =
        _profilePics.child(uid + '.' + imageFile.path.split('.').last);
    UploadTask uploadTask = imageRef.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      imageUrl = await uploadTask.snapshot.ref.getDownloadURL();
    });

    return imageUrl;
  }

  static createProfile({
    required String owner,
    required String name,
    required DateTime birthDate,
    required int gender,
    required double height,
    required double weightLb,
    required double weightOz,
    required String pediatrician,
    required String pediatricianPhone,
    required Map<String, int> allergies,
    required String imagePath,
  }) async {
    String documentId = '';
    DateTime now = DateTime.now();

    await _profileCollection.add({
      'owner': owner,
      'created': DateTime(now.year, now.month, now.day).toString(),
      'name': name,
      'birth_date': birthDate.toString().split(' ').first,
      'gender': gender,
      'height': height,
      'weightLb': weightLb,
      'weightOz': weightOz,
      'pediatrician': pediatrician,
      'pediatrician_phone': pediatricianPhone,
      'allergies': allergies,
      'diaper_changes': {},
      'feedings': {},
      'sleep': {},
    }).then((document) async {
      documentId = document.id;

      File imageFile = File(imagePath);
      String imageUrl = await uploadProfileImage(documentId, imageFile);

      await updateProfileData(
          documentId, {'profile_pic': imageUrl, 'uid': documentId});
    });

    return documentId;
  }

  static updateProfileData(String uid, Map<String, dynamic> fields) async {
    DocumentReference profileDocument = _profileCollection.doc(uid);
    await profileDocument.update(fields);
  }

  static Future getProfileNames(List<String> owned, List<String> shared) async {
    Map<String, List<String?>> profileNames = {};

    await _profileCollection
        .where('uid', whereIn: [...owned, ...shared, ''])
        .get()
        .then((query) {
          for (var document in query.docs) {
            final data = document.data();
            profileNames[document.id] = [
              data['name'] as String,
              data['owner'] as String?,
            ];
          }
        });

    return profileNames;
  }

  // retrieves profile data from the database, or creates it if not yet created
  static Future<Map<String, dynamic>> getProfileData(String uid) async {
    Map<String, dynamic> profileData = {};

    DocumentReference profileDocument = _profileCollection.doc(uid);
    await profileDocument.get().then((document) {
      if (document.exists) {
        profileData = document.data() as Map<String, dynamic>;
      }
    });

    return profileData;
  }

  // sets data sync for profile data with database
  static setProfileDataSync(String uid, Function update) {
    if (_profileListener != null) {
      _profileListener.cancal();
    }

    DocumentReference profileDocument = _profileCollection.doc(uid);

    _profileListener = profileDocument.snapshots().listen((document) {
      update(document.data() as Map<String, dynamic>);
    });
  }

  // removes data sync for profile data with database
  static removeProfileDataSync(String uid) {
    if (_profileListener == null) return;

    _profileListener.cancel();
    _profileListener = null;
  }

  // retrieves the current qod data from local storage or api
  static Future getQOD() async {
    final preferences = await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    String today = DateTime(now.year, now.month, now.day).toString();

    // [0] = date, [1] = message, [2] = author, [3] = imageUrl
    List<String> qod = preferences.getStringList('qod') ?? [];

    if (qod.isEmpty || qod[0] != today) {
      // fetch qod from api
      try {
        var response = await http
            .get(Uri.parse('http://quotes.rest/qod.json?category=inspire'));

        if (response.statusCode == 200) {
          Map<String, dynamic> qodData =
              jsonDecode(response.body)['contents']['quotes'][0];
          qod = [
            today,
            qodData['quote'],
            qodData['author'],
          ];

          preferences.setStringList('qod', qod);
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    return qod;
  }
}
