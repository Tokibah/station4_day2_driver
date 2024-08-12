import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String id;
  final DateTime date;
  final String destinaton;
  final String origin;
  final String fee;
  final bool status;

  Ride(
      {required this.id,
      required this.date,
      required this.destinaton,
      required this.origin,
      required this.fee,
      required this.status});

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
        id: map['id'],
        date: DateTime.parse(map['date']),
        destinaton: map['destination'],
        origin: map['origin'],
        fee: map['fee'],
        status: map['status']);
  }

  static Future<List<Ride>> getRide(List<DocumentReference>? refList) async {
    try {
      List<Ride> rideList = [];
      if (refList != null) {
        for (var ref in refList) {
          final map = await FirebaseFirestore.instance.collection('Ride').doc(ref.id).get();
          rideList.add(Ride.fromMap(map.data()!));
        }
      }
      return rideList;
    } catch (e) {
      print("ERROR GETRIDE: $e");
      return [];
    }
  }
}
