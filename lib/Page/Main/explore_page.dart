import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wsmb_rider/Modal/ride_repo.dart';
import 'package:wsmb_rider/Modal/ridecard_repo.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/Page/Main/ride_card_view.dart';
import 'package:wsmb_rider/main.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.user});
  final String user;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<RideCard> ridecardList = [];
  Rider? rider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    rider = await Rider.getRider(widget.user);
    final rideMap = await FirebaseFirestore.instance.collection('Ride').get();
    final allRide = rideMap.docs.map((e) => Ride.fromMap(e.data())).toList();
    ridecardList = await RideCard.createRideCard(allRide);
    ridecardList = ridecardList
        .where((e) => !rider!.join!.contains(
            FirebaseFirestore.instance.collection('Ride').doc(e.ride.id)))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  Widget autofield(
      {required String label,
      required TextEditingController control,
      required FocusNode focus}) {
    return TextField(
      focusNode: focus,
      controller: control,
      decoration: InputDecoration(hintText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 100,
                    color: ThemeProvider.honeydew,
                    child: const TextField(),
                  ),
                  RideCardView(
                    rideCard: ridecardList,
                    rider: rider,
                    refresh: getData,
                  )
                ],
              ));
  }
}
