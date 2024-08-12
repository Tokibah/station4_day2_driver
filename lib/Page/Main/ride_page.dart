import 'package:flutter/material.dart';
import 'package:wsmb_rider/Modal/ride_repo.dart';
import 'package:wsmb_rider/Modal/ridecard_repo.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/main.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key, required this.user});
  final String user;

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  bool isloading = true;
  Rider? user;
  Set<String> selected = {"active"};
  List<RideCard> ridecard = [];
  bool isJoin = true;
  String totalfee = 'RM0:00';
  List<RideCard> filter = [];
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  String formatTime(DateTime date) {
    final time = TimeOfDay(hour: date.hour, minute: date.minute);
    return "${date.day}/${date.month}/${date.year} ${time.format(context)}";
  }

  void getData() async {
    setState(() {
      isloading = true;
    });
    user = await Rider.getRider(widget.user);
    List<Ride> rideList = await Ride.getRide(user!.join);
    ridecard = await RideCard.createRideCard(rideList);
    applyFilter();
    countTotal();
  }

  void countTotal() async {
    user = await Rider.getRider(widget.user);
    List<Ride> rideList = await Ride.getRide(user!.join);
    List<Ride> ridecan = await Ride.getRide(user!.cancel);

    double total = 0.0;
    for (var ride in rideList) {
      final feeS = ride.fee.replaceRange(0, 2, '');
      total += double.parse(feeS);
    }
    for (var ride in ridecan) {
      final feeS = ride.fee.replaceRange(0, 1, '');
      total += double.parse(feeS);
    }
    totalfee = "RM${total.toStringAsFixed(2)}";

    setState(() {
      isloading = false;
    });
  }

  void applyFilter() async {
    filter = ridecard;
    if (selected.contains("active")) {
      filter = ridecard.where((e) => e.ride.status == true).toList();
      isActive = true;
    }
    if (selected.contains("inactive")) {
      filter = ridecard.where((e) => e.ride.status == false).toList();
      isActive = false;
    }
    if (selected.contains("cancel")) {
      List<Ride> rideList = await Ride.getRide(user!.cancel);
      filter = await RideCard.createRideCard(rideList);
      isActive = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Total fee:\n$totalfee",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            segments: const [
              ButtonSegment(value: "active", label: Text('Active')),
              ButtonSegment(value: "inactive", label: Text('Inactive')),
              ButtonSegment(value: "cancel", label: Text('Cancel'))
            ],
            selected: selected,
            onSelectionChanged: (value) {
              selected = value;
              getData();
            },
          ),
        ),
        SizedBox(
            height: 380,
            child: ridecard.isEmpty
                ? const Center(child: Text('No ride available'))
                : isloading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filter.length,
                        itemBuilder: (context, index) {
                          RideCard card = filter[index];
                          return Opacity(
                            opacity: isActive ? 1 : 0.6,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all()),
                              margin: const EdgeInsets.all(10),
                              height: 100,
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              NetworkImage(card.driver.image),
                                        ),
                                      ),
                                      Text(card.driver.name)
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                card.ride.origin,
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                              const Icon(Icons.arrow_forward),
                                              Text(
                                                card.ride.destinaton,
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(card.ride.fee),
                                              const Spacer(),
                                              Text(
                                                formatTime(card.ride.date),
                                                style: const TextStyle(
                                                    backgroundColor:
                                                        ThemeProvider.pop),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    color: ThemeProvider.honeydew,
                                    child: Center(
                                      child: IconButton(
                                          onPressed: () {
                                            Rider.toggleCancel(
                                                user!, card.ride);
                                            setState(() {
                                              getData();
                                            });
                                          },
                                          icon: Icon(selected.contains("cancel")
                                              ? Icons.delete
                                              : Icons.cancel)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
        SizedBox(
            width: double.infinity,
            child:
                ElevatedButton(onPressed: getData, child: Icon(Icons.refresh)))
      ]),
    );
  }
}
