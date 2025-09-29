import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      try {
        return AppUser.fromMap(doc.data()!);
      } catch (e) {
        log(e.toString());
      }
    }

    return null;
  }
}
