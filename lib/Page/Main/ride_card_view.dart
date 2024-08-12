import 'package:flutter/material.dart';
import 'package:wsmb_rider/Modal/ridecard_repo.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/main.dart';

class RideCardView extends StatefulWidget {
  const RideCardView(
      {super.key,
      required this.rideCard,
      required this.rider,
      required this.refresh});

  final List<RideCard> rideCard;
  final Rider? rider;
  final Function refresh;

  @override
  State<RideCardView> createState() => _RideCardViewState();
}

class _RideCardViewState extends State<RideCardView> {
  Widget tile({required String title, required IconData icon}) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Row(
        children: [
          Icon(
            icon,
            color: ThemeProvider.trust,
          ),
          Text(title)
        ],
      ),
    );
  }

  void showBottom(RideCard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: ThemeProvider.trust,
                height: 130,
                width: double.infinity,
                child: Center(
                    child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(card.driver.image),
                      ),
                    ),
                    Text(card.driver.name),
                  ],
                )),
              ),
              tile(title: card.driver.gender, icon: Icons.person),
              tile(title: card.driver.email, icon: Icons.email),
              tile(title: card.driver.address, icon: Icons.map),
              tile(title: card.driver.phone, icon: Icons.phone),
              const Divider(),
              tile(title: card.car.modal, icon: Icons.car_crash),
              const Text("Special Feature:"),
              Container(
                decoration: BoxDecoration(border: Border.all()),
                height: 100,
                width: double.infinity,
                child: Center(child: Text("-${card.car.feat}")),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.ride.origin,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Icon(Icons.arrow_forward),
                  Text(
                    card.ride.destinaton,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(card.ride.fee),
                    const Spacer(),
                    Text(
                      formatTime(card.ride.date),
                      style:
                          const TextStyle(backgroundColor: ThemeProvider.pop),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () async {
                      Rider.joinRide(card.ride, widget.rider!);
                      widget.refresh;
                      Navigator.pop(context);
                    },
                    child: const Text("Join")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(DateTime date) {
    final time = TimeOfDay(hour: date.hour, minute: date.minute);
    return "${date.day}/${date.month}/${date.year} ${time.format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 410,
        child: ListView.builder(
          itemCount: widget.rideCard.length,
          itemBuilder: (context, index) {
            RideCard card = widget.rideCard[index];
            return GestureDetector(
              onTap: () => showBottom(card),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all()),
                margin: const EdgeInsets.all(10),
                height: 150,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(card.driver.image),
                          ),
                        ),
                        Text(card.driver.name)
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  card.ride.origin,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const Icon(Icons.arrow_forward),
                                Text(
                                  card.ride.destinaton,
                                  style: const TextStyle(fontSize: 20),
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
                                      backgroundColor: ThemeProvider.pop),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
