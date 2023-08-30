import 'package:flutter/material.dart';
import 'package:stolen_devices_recovery/services/auth.dart';
import 'package:stolen_devices_recovery/shared/loading.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage>
    with SingleTickerProviderStateMixin {
  /// TODO Variable
  Animation? animation;
  AnimationController? animationController;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController userEmailController = new TextEditingController();
  bool isLoading = false;

  /// TODO initState
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    // it flying from left side towards center
    // -ve value mean it start from left side
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.bounceOut,
    ));
  }

  /// TODO Forgot Password Method
  forgotPwdMethod() async {
    try {
      if (formKey.currentState!.validate()) {
        setState(() => isLoading = true);
        // final FirebaseAuth _auth = FirebaseAuth.instance;
        // await _auth.sendPasswordResetEmail(email: userEmailController.text);
        await AuthService().resetForgotPassword(userEmailController.text);
        Navigator.of(context).pop();
        showToaster("Password sent to your email !");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    animationController!.forward();
    return isLoading
        ? Loading()
        : AnimatedBuilder(
            animation: animationController!,
            builder: (BuildContext context, Widget? child) {
              return Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Transform(
                      transform: Matrix4.translationValues(
                          animation!.value * width, 0.0, 0.0),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.12,
                              width: MediaQuery.of(context).size.width * 0.56,
                              decoration: stackTopLeftCornerIconDecoration(),
                              child: Center(
                                child: Text(
                                  'Forgot\nPassword ?',
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height - 50,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// TODO Text 1
                                Container(
                                  padding:
                                      EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Text(
                                    'Enter email address associated with your account.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      height: 1.5,
                                      fontFamily: 'Times New Roman',
                                      color: Colors.white,
                                      // color: Color(0xffff2fc3),
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),

                                /// TODO Text 2
                                Container(
                                  padding:
                                      EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: Text(
                                    'We\'ll email you a link to reset your password !!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      height: 1.5,
                                      fontFamily: 'Times New Roman',
                                      color: Colors.white60,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),

                                /// TODO Form
                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                    style: simpleTextStyle(),
                                    decoration: textFieldInputDecoration(
                                      'Email',
                                      Icon(Icons.email_outlined,
                                          color: fieldIconColor),
                                    ),
                                    controller: userEmailController,
                                    validator: (val) {
                                      return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                      ).hasMatch(val!)
                                          ? null
                                          : "Valid email required";
                                    },
                                  ),
                                ),
                                SizedBox(height: 50.0),

                                /// TODO SignIn Button
                                GestureDetector(
                                  onTap: () => forgotPwdMethod(),
                                  child: Container(
                                    height: 40.0,
                                    child: Material(
                                      shape: shapeFiftyCircular(),
                                      color: loginRegisterForgotPwdButtonColor,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Send Link',
                                                style: textInsideButtonStyle()),
                                            Icon(Icons.arrow_forward,
                                                color: iconInsideButtonColors),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
