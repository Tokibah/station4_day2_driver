import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_rider/Modal/ride_repo.dart';

class Rider {
  final String id;
  final String gender;
  final String name;
  final String ic;
  String pass;
  final String email;
  final String phone;
  final String address;
  String? image;
  List<DocumentReference>? join;
  List<DocumentReference>? cancel;

  Rider(
      {required this.id,
      required this.gender,
      required this.name,
      required this.ic,
      required this.pass,
      required this.email,
      required this.phone,
      required this.address,
      this.image,
      this.join,
      this.cancel});

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'id': id,
      'name': name,
      'ic': ic,
      'pass': pass,
      'email': email,
      'phone': phone,
      'address': address,
      'image': image,
      'join': join,
      'cancel': cancel
    };
  }

  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
        gender: map['gender'],
        id: map['id'],
        name: map['name'],
        ic: map['ic'],
        pass: map['pass'],
        email: map['email'],
        phone: map['phone'],
        address: map['address'],
        image: map['image'],
        join: List<DocumentReference>.from(map['join'] ?? []),
        cancel: List<DocumentReference>.from(map['cancel'] ?? []));
  }

  static final firestore = FirebaseFirestore.instance.collection('Rider');

  static Future<bool> isDupliRider(String icNum, String phoneNum) async {
    try {
      final que = [
        firestore.where('ic', isEqualTo: icNum).get(),
        firestore.where('phone', isEqualTo: phoneNum).get(),
      ];

      final snap = await Future.wait(que);

      return snap.any((que) => que.docs.isNotEmpty);
    } catch (e) {
      print("ERROR ISDUPLIRIDER: $e");
      return false;
    }
  }

  static void uploadPhoto(File image, Rider rider) async {
    try {
      if (rider.image != null) {
        await FirebaseStorage.instance.refFromURL(rider.image!).delete();
      }
      final upTask = await FirebaseStorage.instance
          .ref("Images/${DateTime.now().microsecondsSinceEpoch}.jpg")
          .putFile(image);

      final url = await upTask.ref.getDownloadURL();

      await firestore.doc(rider.id).update({'image': url});
    } catch (e) {
      print("ERROR UPLOADPHOTO: $e");
    }
  }

  static Future<void> addRider(Rider newRider) async {
    try {
      final byte = utf8.encode(newRider.pass);
      final hash = sha224.convert(byte).toString();
      newRider.pass = hash;

      await firestore.doc(newRider.id).set(newRider.toMap());
    } catch (e) {
      print("ERROR ADDRIDER: $e");
    }
  }

  static Future<Rider?> getRider(String id) async {
    try {
      final user = await firestore.doc(id).get();
      if (user.exists) {
        return Rider.fromMap(user.data()!);
      }

      return null;
    } catch (e) {
      print("ERROR GETRIDER: $e");
      return null;
    }
  }

  static Future<String?> login(String icNum, String pass) async {
    try {
      final byte = utf8.encode(pass);
      final hash = sha224.convert(byte).toString();
      final userMap = await firestore
          .where('ic', isEqualTo: icNum)
          .where('pass', isEqualTo: hash)
          .get();

      Rider? user = await getRider(userMap.docs.first.id);

      if (user != null) {
        final pref = await SharedPreferences.getInstance();
        await pref.setString('token', user.id);
      }

      return user?.id;
    } catch (e) {
      print("ERRROR LOGIN:$e");
      return null;
    }
  }

  static void joinRide(Ride ride, Rider rider) async {
    final ref = FirebaseFirestore.instance.collection('Ride').doc(ride.id);
    await firestore.doc(rider.id).update({
      'join': FieldValue.arrayUnion([ref])
    });
  }

  static void toggleCancel(Rider rider, Ride ride) async {
    final ref = FirebaseFirestore.instance.collection('Ride').doc(ride.id);
    if (rider.cancel!.contains(ref)) {
      rider.cancel!.removeWhere((e) => e == ref);
    } else {
      rider.cancel!.add(ref);
      rider.join!.removeWhere((e) => e == ref);
    }
    await FirebaseFirestore.instance
        .collection('Rider')
        .doc(rider.id)
        .update({'cancel': rider.cancel, 'join': rider.join});
  }
}
