import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int currStep = 0;

  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _ic = TextEditingController();
  final _pass = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  File? _file;

  @override
  void initState() {
    super.initState();
    checkPemis();
  }

  void checkPemis() async {
    await [Permission.camera, Permission.mediaLibrary].request();
  }

  Widget textfield(
      {required String label,
      required TextEditingController control,
      required Function(String) valid}) {
    return TextFormField(
      decoration: InputDecoration(hintText: label),
      controller: control,
      validator: (value) => valid(value!),
    );
  }

  void choosePhoto(bool isCam) async {
    final tempFile = await ImagePicker()
        .pickImage(source: isCam ? ImageSource.camera : ImageSource.gallery);
    if (tempFile != null) {
      _file = File(tempFile.path);
      setState(() {});
    }
  }

  void showSnackBar(String mes) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mes)));
  }

  void sumbitUser() async {
    if (_file == null) {
      showSnackBar("Please choose an image");
    } else if (await Rider.isDupliRider(_ic.text, _phone.text)) {
      showSnackBar("Ic or phone number already exist");
    } else {
      final last = _ic.text.substring(_ic.text.length - 1);

      Rider tempRider = Rider(
          gender: int.parse(last) & 2 == 0 ? "Female" : "Male",
          id: Label.getLabel(),
          name: _name.text,
          ic: _ic.text,
          pass: _pass.text,
          email: _email.text,
          phone: _phone.text,
          address: _address.text);

      await Rider.addRider(tempRider);
      Rider.uploadPhoto(_file!, tempRider);
      showSnackBar("Account created");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Information'),
      ),
      body: Stepper(
          currentStep: currStep,
          onStepCancel: () {
            if (currStep != 0) {
              setState(() {
                currStep -= 1;
              });
            }
          },
          onStepContinue: () {
            switch (currStep) {
              case (0):
                {
                  if (_formkey.currentState!.validate()) {
                    currStep += 1;
                  }
                  break;
                }
              case (1):
                {
                  if (_formkey2.currentState!.validate()) {
                    currStep += 1;
                  }
                  break;
                }
              default:
                sumbitUser();
            }
            setState(() {});
          },
          steps: [
            Step(
                title: const Icon(Icons.person),
                content: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      textfield(
                          label: "Name...",
                          control: _name,
                          valid: (value) => value.isNotEmpty
                              ? null
                              : "Please fill in your name..."),
                      textfield(
                          label: "IC. Number...",
                          control: _ic,
                          valid: (value) => RegExp(r'\d+').hasMatch(value) &&
                                  value.length == 12
                              ? null
                              : "Invalid IC. number...(eg. 12342384231)"),
                      textfield(
                          label: "Password...",
                          control: _pass,
                          valid: (value) => value.isNotEmpty
                              ? null
                              : "Please fill in your password..."),
                    ],
                  ),
                )),
            Step(
                title: const Row(
                  children: [Icon(Icons.email), Icon(Icons.phone)],
                ),
                content: Form(
                  key: _formkey2,
                  child: Column(
                    children: [
                      textfield(
                          label: "Email...(eg. exam@gmail)",
                          control: _email,
                          valid: (value) => RegExp(r'.+@.+').hasMatch(value)
                              ? null
                              : "Invalid email..."),
                      textfield(
                          label: "Phone Number...(eg. +60455342335)",
                          control: _phone,
                          valid: (value) => RegExp(r'^\+\d+').hasMatch(value) &&
                                  value.length == 12
                              ? null
                              : "Invalid Phone Number..."),
                      textfield(
                          label: "Address...",
                          control: _address,
                          valid: (value) => value.isNotEmpty
                              ? null
                              : "Please fill in your address..."),
                    ],
                  ),
                )),
            Step(
                title: const Icon(Icons.image),
                content: Column(
                  children: [
                    Wrap(
                      spacing: 20,
                      children: [
                        ElevatedButton(
                            onPressed: () => choosePhoto(true),
                            child: const Text('Camera')),
                        ElevatedButton(
                            onPressed: () => choosePhoto(false),
                            child: const Text('Gallery'))
                      ],
                    ),
                    if (_file != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(_file!),
                        ),
                      )
                  ],
                ))
          ]),
    );
  }
}
