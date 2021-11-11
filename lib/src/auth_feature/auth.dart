import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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
        Text(
          'Forward Fencing Classes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        const SizedBox(height: 16),
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: 'US'),
          onInputChanged: (PhoneNumber value) {
            phoneController.text = "${value.dialCode}${value.parseNumber()}";
          },
        ),
        const SizedBox(height: 16),
        InkButton(
          onPressed: () async {
            if (phoneController.text.length < 12) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Phone number entered incorrectly!"),
                ),
              );
            } else {
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
            }
          },
          text: "Continue",
        ),
        const Spacer(),
      ],
    );
  }

  Widget getOtpFormWidget(context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          'Forward Fencing Classes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        const SizedBox(height: 16),
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
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).orientation == Orientation.landscape
                ? 600
                : null,
            child: showLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : currentState == MobileVerificationState.mobileFormState
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget(context),
            padding: const EdgeInsets.all(16),
          ),
        ));
  }
}
