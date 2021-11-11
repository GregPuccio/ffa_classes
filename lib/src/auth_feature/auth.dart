import 'package:ffaclasses/src/class_list_wrapper/class_list_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

enum MobileVerificationState {
  mobileFormState,
  otpFormState,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = 'auth';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

Stream<User?> authChanges() {
  return _auth.authStateChanges();
}

void signOut() async {
  return _auth.signOut();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.mobileFormState;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  late String verificationId;
  late ConfirmationResult result;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      AuthCredential? phoneAuthCredential) async {
    if (phoneAuthCredential != null) {
      setState(() {
        showLoading = true;
      });
      try {
        final authCredential =
            await _auth.signInWithCredential(phoneAuthCredential);

        setState(() {
          showLoading = false;
        });

        if (authCredential.user != null) {
          Navigator.pushReplacementNamed(context, ClassListWrapper.routeName);
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          showLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message!)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please input sms code received after verifying phone number'),
        ),
      );
    }
  }

  Widget getMobileFormWidget(context) {
    return Column(
      children: [
        const Spacer(),
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            hintText: "Phone Number",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        MaterialButton(
          onPressed: () async {
            setState(() {
              showLoading = true;
            });

            if (identical(0, 0.0)) {
              try {
                result = await _auth.signInWithPhoneNumber(
                  phoneController.text,
                );
                setState(() {
                  showLoading = false;
                  currentState = MobileVerificationState.otpFormState;
                });
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message!),
                  ),
                );
                setState(() {
                  showLoading = false;
                });
              }
            } else {
              await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (verificationFailed) async {
                  setState(() {
                    showLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(verificationFailed.message!)));
                },
                codeSent: (verificationId, resendingToken) async {
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.otpFormState;
                    this.verificationId = verificationId;
                  });
                },
                codeAutoRetrievalTimeout: (verificationId) async {},
              );
            }
          },
          child: const Text("SEND"),
          color: Colors.blue,
          textColor: Colors.white,
        ),
        const Spacer(),
      ],
    );
  }

  Widget getOtpFormWidget(context) {
    return Column(
      children: [
        const Spacer(),
        TextField(
          controller: otpController,
          decoration: const InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        MaterialButton(
          onPressed: () async {
            if (identical(0, 0.0)) {
              await result.confirm(otpController.text);
            } else {
              PhoneAuthCredential phoneAuthCredential =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text);

              signInWithPhoneAuthCredential(phoneAuthCredential);
            }
          },
          child: const Text("VERIFY"),
          color: Colors.blue,
          textColor: Colors.white,
        ),
        const Spacer(),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : currentState == MobileVerificationState.mobileFormState
                  ? getMobileFormWidget(context)
                  : getOtpFormWidget(context),
          padding: const EdgeInsets.all(16),
        ));
  }
}
