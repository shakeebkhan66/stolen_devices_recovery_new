import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stolen_devices_recovery/helper/helperFunctions.dart';
import 'package:stolen_devices_recovery/product_console/productDashboard.dart';
import 'package:stolen_devices_recovery/screens/forgetPassword.dart';
import 'package:stolen_devices_recovery/services/auth.dart';
import 'package:stolen_devices_recovery/services/database.dart';
import 'package:stolen_devices_recovery/shared/loading.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';
import 'signUp.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  /// TODO Variables
  Animation? animation;
  AnimationController? animationController;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController userEmailController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  bool isLoading = false;
  bool _isObscure = true;

  /// TODO initState
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    // it flying from left side towards center
    // -ve value mean it start from left side
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.fastOutSlowIn,
    ));
  }

  /// TODO Sign in Method
  signInMethod() async {
    try {
      if (formKey.currentState!.validate()) {
        setState(() => isLoading = true);
        await AuthService()
            .signInWithEmailAndPassword(
                userEmailController.text, userPasswordController.text)
            .then((result) async {
          if (result != null) {
            QuerySnapshot snapshotUserInfo = await DatabaseService()
                .getUserByUserEmail(userEmailController.text);
            if (snapshotUserInfo.docs.length > 0) {
              HelperFunctions.saveUserLoggedInSharedPreference(true);
              // 0 index mean we get only one document of "Name" from firebase
              HelperFunctions.saveUserNameSharedPreference(
                  snapshotUserInfo.docs[0]['Name']);
              // HelperFunctions.saveUserEmailSharedPreference(
              //     userEmailController.text);
              HelperFunctions.saveUserEmailSharedPreference(
                  snapshotUserInfo.docs[0]['Email']);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ProductDashboard()));
            } // third IF
          } // second IF
          else {
            setState(() => isLoading = false);
            showToaster(
              "Register and verify yourself ! \nOR\n Enter valid credentials ! ",
            );
          }
        });
      } // first IF
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
                          Container(
                            padding: EdgeInsets.fromLTRB(15.0, 100.0, 0.0, 0.0),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(140.0, 80.0, 0.0, 0.0),
                            child: Text(
                              '.',
                              style: TextStyle(
                                fontSize: 80.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFFC069),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 220.0),
                            child: Column(
                              children: [
                                /// TODO Form
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        // email
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          decoration: textFieldInputDecoration(
                                            'EMAIL',
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
                                        SizedBox(height: 10.0),
                                        // password
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          obscureText: _isObscure,
                                          decoration:
                                              passwordViewInputDecoration(
                                            'PASSWORD',
                                            Icon(Icons.vpn_key,
                                                color: fieldIconColor),
                                            GestureDetector(
                                              onTap: () => setState(() =>
                                                  _isObscure = !_isObscure),
                                              child: Icon(
                                                  _isObscure
                                                      ? Icons.visibility
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: fieldIconColor),
                                            ),
                                          ),
                                          controller: userPasswordController,
                                          validator: (val) {
                                            return val!.isEmpty || val.length < 6
                                                ? 'Wrong password!'
                                                : null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// TODO Forgot Password
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgetPasswordPage()),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.only(top: 25.0, right: 20.0),
                                    child: Text(
                                      'Forgot Password ?',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),

                                /// TODO SignIn Button
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(15.0, 40.0, 15, 0.0),
                                  child: GestureDetector(
                                    onTap: () => signInMethod(),
                                    child: Container(
                                      height: 40.0,
                                      child: Material(
                                        shape: shapeFiftyCircular(),
                                        color:
                                            loginRegisterForgotPwdButtonColor,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Login',
                                                  style:
                                                      textInsideButtonStyle()),
                                              Icon(Icons.arrow_forward,
                                                  color:
                                                      iconInsideButtonColors),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// TODO Don't have an account
                                Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Don\'t have an account ? ',
                                          style: simpleTextStyle()),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RegisterPage()),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
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
