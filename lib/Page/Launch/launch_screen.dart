import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wsmb_rider/Modal/rider_repo.dart';
import 'package:wsmb_rider/Page/Launch/sign_up.dart';
import 'package:wsmb_rider/Page/Main/push_Navigate.dart';
import 'package:wsmb_rider/main.dart';

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animate;
  late Animation<Offset> _slide;

  final _ic = TextEditingController();
  final _pass = TextEditingController();

  Widget textfield(
      {required String label, required TextEditingController control}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: control,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              fillColor: ThemeProvider.light,
              filled: true),
        ),
      ],
    );
  }

  void loginUser() async {
    String? user = await Rider.login(_ic.text, _pass.text);
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid user')));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => PushNavigate(userId: user)));
    }
  }

  @override
  void initState() {
    super.initState();

    _animate = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat(reverse: true);

    _slide = Tween(begin: const Offset(-2, 0), end: const Offset(1, 0)).animate(_animate);
  }

  @override
  void dispose() {
    _animate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeProvider.honeydew,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  'KONGSI\nKERETA',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      decoration: TextDecoration.underline,
                      decorationColor: ThemeProvider.pop,
                      decorationStyle: TextDecorationStyle.dashed,
                      decorationThickness: 2),
                ),
                const SizedBox(height: 60),
                SlideTransition(
                  position: _slide,
                  child: SizedBox(
                    height: 100,
                    child: Wrap(
                      runSpacing: 10,
                      direction: Axis.vertical,
                      children: List.generate(
                          10,
                          (_) => const FaIcon(
                                FontAwesomeIcons.carSide,
                                size: 100,
                              )),
                    ),
                  ),
                ),
                textfield(label: "IC. number", control: _ic),
                textfield(label: "Password", control: _pass),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          onPressed: loginUser, child: const Text('LOGIN'))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dont have an acccount?'),
                    TextButton(
                        onPressed: () =>
                            Navigator.push(context, SizeRoute(page: const SignUp())),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(color: ThemeProvider.trust),
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
