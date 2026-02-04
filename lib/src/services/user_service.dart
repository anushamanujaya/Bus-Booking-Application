import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static User get user => _auth.currentUser!;
  static String get uid => user.uid;

  /// Save/update basic user info in Firestore
  static Future<void> upsertUserDoc() async {
    final u = _auth.currentUser;
    if (u == null) return;

    await _db.collection('users').doc(u.uid).set({
      'name': u.displayName ?? '',
      'email': u.email ?? '',
      'photoUrl': u.photoURL ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Upload profile picture → Storage → update auth profile → save url in Firestore
  static Future<String> uploadProfileImage(File file) async {
    final ref = _storage.ref('users/$uid/profile.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await user.reload();

    await _db.collection('users').doc(uid).set({
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return url;
  }

  /// (OLD) Add a booking record per seat into: users/{uid}/history/{autoId}
  /// You can still keep this if you want history per seat.
  static Future<void> addHistory({
    required String tripId,
    required String seatNo,
    String? route,
    String? busNo,
    num? price,
  }) async {
    await _db.collection('users').doc(uid).collection('history').add({
      'tripId': tripId,
      'seatNo': seatNo,
      'route': route ?? '',
      'busNo': busNo ?? '',
      'price': price ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save ONE ticket per booking with multiple seats + reference number
  static Future<void> addTicketHistory({
    required String tripId,
    required String from,
    required String to,
    required String route,
    required String busNo,
    required String refNo,
    required List<String> seats,
    required num pricePerSeat,
    required num totalPrice,
  }) async {
    await _db.collection('users').doc(uid).collection('history').add({
      'tripId': tripId,
      'from': from,
      'to': to,
      'route': route,
      'busNo': busNo,
      'refNo': refNo,
      'seats': seats,
      'seatCount': seats.length,
      'pricePerSeat': pricePerSeat,
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
