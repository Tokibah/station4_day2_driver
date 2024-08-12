import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/Page/Launch/launch_screen.dart';
import 'package:wsmb_rider/Page/Main/explore_page.dart';
import 'package:wsmb_rider/Page/Main/ride_page.dart';
import 'package:wsmb_rider/main.dart';

class PushNavigate extends StatefulWidget {
  const PushNavigate({super.key, required this.userId});
  final String userId;

  @override
  State<PushNavigate> createState() => PushNavigateState();
}

class PushNavigateState extends State<PushNavigate> {
  int currIndex = 0;
  Rider? profileUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    profileUser = await Rider.getRider(widget.userId);
    setState(() {
      isLoading = false;
    });
  }

  Widget tile({required String title, required IconData icon}) {
    return SizedBox(
      height: 40,
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

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('token');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LaunchScreen()));
  }

  void pickImage(bool isCam) async {
    final tempfile = await ImagePicker()
        .pickImage(source: isCam ? ImageSource.camera : ImageSource.gallery);
    if (tempfile != null) {
      Rider.uploadPhoto(File(tempfile.path), profileUser!);
      profileUser = await Rider.getRider(profileUser!.id);
      Navigator.pop(context);
    }
  }

  void showBottomDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
              height: 120,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        pickImage(true);
                        Navigator.pop(context);
                      },
                      leading: const Icon(Icons.camera),
                      title: const Text("Camera"),
                    ),
                    ListTile(
                      onTap: () async {
                        pickImage(false);
                        Navigator.pop(context);
                      },
                      leading: const Icon(Icons.image),
                      title: const Text("Gallery"),
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> showProfile() async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: showBottomDialog,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(profileUser!.image!),
                          ),
                        ),
                        Text(profileUser!.name),
                        tile(title: profileUser!.ic, icon: Icons.person),
                        tile(title: profileUser!.gender, icon: Icons.person),
                        tile(title: profileUser!.phone, icon: Icons.phone),
                        tile(title: profileUser!.email, icon: Icons.email),
                        tile(title: profileUser!.address, icon: Icons.map),
                        GestureDetector(
                          onTap: logout,
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.red[100],
                                border: const Border.symmetric(
                                    horizontal: BorderSide(width: 2))),
                            child: const Center(child: Text('LOGOUT')),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox.shrink()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PopScope(
                    onPopInvokedWithResult: (_, __) async {
                      await Future.delayed(const Duration(seconds: 1));
                      getData();
                    },
                    child: GestureDetector(
                      onTap: showProfile,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(profileUser!.image!),
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: IndexedStack(
              index: currIndex,
              children: [
                ExplorePage(user: widget.userId),
                RidePage(user: widget.userId)
              ],
            ),
            bottomNavigationBar: NavigationBar(
                selectedIndex: currIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    currIndex = value;
                  });
                },
                destinations: const [
                  NavigationDestination(
                      icon: FaIcon(FontAwesomeIcons.microscope),
                      label: 'Explore'),
                  NavigationDestination(
                      icon: FaIcon(FontAwesomeIcons.car), label: 'Ride')
                ]),
          );
  }
}
