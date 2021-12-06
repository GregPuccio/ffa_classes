import 'package:ffaclasses/src/auth_feature/auth_service.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:email_validator/email_validator.dart';

enum AuthScreenState {
  signIn,
  register,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = 'auth';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthScreenState currentState = AuthScreenState.signIn;

  late TextEditingController emailController;
  late TextEditingController passwordController;
  TextEditingController? forgotPassController;
  bool obscure = true;

  late String verificationId;
  late ConfirmationResult result;

  bool showLoading = false;

  void registerAccount() async {
    try {
      final authCredential = await AuthService()
          .register(emailController.text, passwordController.text);

      if (authCredential.user == null) {
        setState(() {
          showLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  Future forgotPassword() {
    forgotPassController = TextEditingController(text: emailController.text);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter the email address that you use for your account below.",
            ),
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              controller: forgotPassController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () async {
              if (EmailValidator.validate(forgotPassController!.text)) {
                final dynamic result = await AuthService()
                    .forgotPassword(forgotPassController!.text);
                if (result.runtimeType == String) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(result),
                  ));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "If the email address entered has an account associated, an email has been sent to the address."),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please enter a valid email."),
                ));
              }
            },
            child: const Text("SEND EMAIL"),
          ),
        ],
      ),
    );
  }

  Widget getSignIn(context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          'Forward Fencing Classes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.mail),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              ),
            ),
            obscureText: obscure,
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: TextButton(
            child: const Text("Forgot password?"),
            onPressed: () => forgotPassword(),
          ),
        ),
        const SizedBox(height: 8),
        InkButton(
          onPressed: () async {
            if (EmailValidator.validate(emailController.text)) {
              setState(() {
                showLoading = true;
              });
              dynamic result = await AuthService()
                  .signIn(emailController.text, passwordController.text);
              if (result.runtimeType == String) {
                setState(() {
                  showLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Email address is badly formatted."),
                ),
              );
            }
          },
          text: "Sign In",
        ),
        const Spacer(),
        SecondaryButton(
          text: "Create an account",
          active: true,
          onPressed: () {
            setState(() {
              currentState = AuthScreenState.register;
            });
          },
        ),
      ],
    );
  }

  Widget getRegistration(context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          'Forward Fencing Classes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.mail),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              ),
            ),
            obscureText: obscure,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlutterPwValidator(
            controller: passwordController,
            minLength: 6,
            width: 400,
            height: 30,
            onSuccess: () {},
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkButton(
          onPressed: () async {
            if (EmailValidator.validate(emailController.text)) {
              if (passwordController.text.length >= 6) {
                dynamic result = await AuthService()
                    .register(emailController.text, passwordController.text);
                if (result.runtimeType == String) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Please meet the minimum password requirements."),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter a valid email address."),
                ),
              );
            }
          },
          text: "Register",
        ),
        const Spacer(),
        SecondaryButton(
          text: 'Already have an account?',
          active: true,
          onPressed: () {
            setState(() {
              currentState = AuthScreenState.signIn;
            });
          },
        ),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    if (forgotPassController != null) {
      forgotPassController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? 600
              : null,
          child: showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : currentState == AuthScreenState.signIn
                  ? getSignIn(context)
                  : getRegistration(context),
        ),
      ),
    );
  }
}
