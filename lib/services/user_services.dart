import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart'; 

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getUserDataMap(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Stream<AppUser?> streamUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromFirestore(snapshot.data()!, uid);
      }
      return null;
    });
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  Future<void> updateUserName(String uid, String name) async {
    await updateUserData(uid, {'name': name});
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> updateUserPhoto(String uid, String photoURL) async {
    await updateUserData(uid, {'photoURL': photoURL});
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  Future<void> updateUserGender(String uid, String gender) async {
    await updateUserData(uid, {'gender': gender});
  }

  Future<void> updateUserBirthDate(String uid, DateTime birthDate) async {
    await updateUserData(uid, {'birthDate': Timestamp.fromDate(birthDate)});
  }

  Future<void> updateUserPhone(String uid, String phone) async {
    await updateUserData(uid, {'phone': phone});
  }

  Future<void> updateUserBio(String uid, String bio) async {
    await updateUserData(uid, {'bio': bio});
  }

  Future<void> deleteUserData(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }
}