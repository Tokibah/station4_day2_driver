import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wsmb_rider/Modal/driver_repo.dart';
import 'package:wsmb_rider/Modal/ride_repo.dart';
import 'package:wsmb_rider/Modal/vehicle_repo.dart';

class RideCard {
  final Ride ride;
  final Vehicle car;
  final Driver driver;

  RideCard({required this.ride, required this.car, required this.driver});

  static final firestore = FirebaseFirestore.instance;

  static Future<List<RideCard>> createRideCard(List<Ride> rideList) async {
    try {
      List<RideCard> rcList = [];
      for (int i = 0; i < rideList.length; i++) {
        final rideRef = firestore.collection('Ride').doc(rideList[i].id);


        final carMap = await firestore
            .collection('Vehicle')
            .where('ride', arrayContains: rideRef)
            .get();
        final car = Vehicle.fromMap(carMap.docs.first.data());
        final carRef = firestore.collection('Vehicle').doc(car.id);

        final driverMap = await firestore
            .collection('Driver')
            .where('vehicle', isEqualTo: carRef)
            .get();
        final driver = Driver.fromMap(driverMap.docs.first.data());

        rcList.add(RideCard(ride: rideList[i], car: car, driver: driver));
      }
      return rcList;
    } catch (e) {
      print("ERROR CREATERIDECARD: $e");
      return [];
    }
  }
}
