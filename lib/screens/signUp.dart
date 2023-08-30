import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stolen_devices_recovery/helper/helperFunctions.dart';
import 'package:stolen_devices_recovery/services/auth.dart';
import 'package:stolen_devices_recovery/shared/loading.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';
import 'signIn.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // TODO Variables
  Animation? animation;
  AnimationController? animationController;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController userPhoneController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();
  TextEditingController userCNICController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  TextEditingController userConformPwdController = new TextEditingController();
  bool isLoading = false;
  bool _isObscureA = true;
  bool _isObscureB = true;
  String? imageSnap;

  /// Active image file
  XFile? _imageFile;

  /// Select an image via gallery
  Future _pickImage(ImageSource source) async {
    XFile? selected = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
    /// Upload Image to Firebase
    final file = File(selected!.path);
    final destination = "${userEmailController.text}/${DateTime.now()}.png";
    Reference reference =
        FirebaseStorage.instance.ref("Profile_Images/").child(destination);
    UploadTask _uploadTask = reference.putFile(file);
    _uploadTask.whenComplete(() async {
      try {
        String uploadedImageUrl = await reference.getDownloadURL();
        imageSnap = uploadedImageUrl;
        // showToaster("Image uploaded successfully");
        print("This is URL: $imageSnap");
      } catch (e) {
        print(e.toString());
      }
    });
  }

  // TODO initState
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

  // TODO Sign up Method
  signUpMethod() async {
    try {
      if (formKey.currentState!.validate() && imageSnap != null) {
        setState(() => isLoading = true);

        // Upload Image to Firebase
        final file = File(_imageFile!.path);
        final destination = "${userEmailController.text}/${DateTime.now()}.png";
        Reference reference =
            FirebaseStorage.instance.ref("Profile_Images/").child(destination);
        UploadTask _uploadTask = reference.putFile(file);
        _uploadTask.whenComplete(() async {
          try {
            String uploadedImageUrl = await reference.getDownloadURL();
            imageSnap = uploadedImageUrl;
            // showToaster("Image uploaded successfully");
            print("This is URL: $imageSnap");
          } catch (e) {
            print(e.toString());
          }
        });
        await AuthService()
            .registerWithEmailAndPassword(
          userEmailController.text,
          userPasswordController.text,
          userNameController.text,
          userPhoneController.text,
          userCNICController.text,
          imageSnap!,
        )
            .then((value) {
          if (value != null) {
            value.sendEmailVerification();
            showToaster("Email sent for verification");
            HelperFunctions.saveUserLoggedInSharedPreference(true);
            HelperFunctions.saveUserNameSharedPreference(
                userNameController.text);
            HelperFunctions.saveUserEmailSharedPreference(
                userEmailController.text);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            setState(() => isLoading = false);
            showToaster("Already registered");
          }
        }).catchError((e) {
          print(e.toString());
        });
      } else {
        showToaster("Wait Image Uploading!");
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
                          Container(
                            padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(200.0, 30.0, 0.0, 0.0),
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
                            padding: EdgeInsets.only(top: 140.0),
                            child: Column(
                              children: [
                                /// TODO Form
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        /// username
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          decoration: textFieldInputDecoration(
                                            'USERNAME',
                                            Icon(Icons.account_circle,
                                                color: fieldIconColor),
                                          ),
                                          controller: userNameController,
                                          validator: (val) {
                                            return val!.isEmpty || val.length < 3
                                                ? 'Minimum 3+ characters required'
                                                : null;
                                          },
                                        ),
                                        SizedBox(height: 10.0),

                                        /// phone
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          decoration: textFieldInputDecoration(
                                            'PHONE',
                                            Icon(Icons.phone,
                                                color: fieldIconColor),
                                          ),
                                          controller: userPhoneController,
                                          validator: (val) {
                                            return RegExp(
                                              // "^(?:[+0]9)?[0-9]{10,12}",
                                              "^[0-9]{4}-[0-9]{7}",
                                            ).hasMatch(val!)
                                                ? null
                                                : 'Format XXXX-XXXXXXX';
                                          },
                                        ),
                                        SizedBox(height: 10.0),

                                        /// email
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

                                        /// CNIC
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          decoration: textFieldInputDecoration(
                                            "CNIC",
                                            Icon(Icons.credit_card,
                                                color: fieldIconColor),
                                          ),
                                          controller: userCNICController,
                                          validator: (val) {
                                            return RegExp(
                                              // "^[0-9]{5}-[-|]-[0-9]{7}-[-|]-[0-9]{1}",
                                              r"^[0-9]{5}-[0-9]{7}-[0-9]",
                                            ).hasMatch(val!)
                                                ? null
                                                : "Format XXXXX-XXXXXXX-X";
                                          },
                                        ),
                                        SizedBox(height: 10.0),

                                        /// password
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          obscureText: _isObscureA,
                                          decoration:
                                              passwordViewInputDecoration(
                                            'PASSWORD',
                                            Icon(Icons.vpn_key,
                                                color: fieldIconColor),
                                            GestureDetector(
                                              onTap: () => setState(() =>
                                                  _isObscureA = !_isObscureA),
                                              child: Icon(
                                                _isObscureA
                                                    ? Icons.visibility
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: fieldIconColor,
                                              ),
                                            ),
                                          ),
                                          controller: userPasswordController,
                                          validator: (val) {
                                            return val!.isEmpty || val.length < 6
                                                ? 'Minimum 6 characters required'
                                                : null;
                                          },
                                        ),
                                        SizedBox(height: 10.0),

                                        /// conform password
                                        TextFormField(
                                          style: simpleTextStyle(),
                                          obscureText: _isObscureB,
                                          decoration:
                                              passwordViewInputDecoration(
                                            'CONFIRM PASSWORD',
                                            Icon(Icons.vpn_key,
                                                color: fieldIconColor),
                                            GestureDetector(
                                              onTap: () => setState(() =>
                                                  _isObscureB = !_isObscureB),
                                              child: Icon(
                                                _isObscureB
                                                    ? Icons.visibility
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: fieldIconColor,
                                              ),
                                            ),
                                          ),
                                          controller: userConformPwdController,
                                          validator: (val) {
                                            return val ==
                                                    userPasswordController.text
                                                ? null
                                                : 'Password did\'nt matched';
                                          },
                                        ),
                                        SizedBox(height: 10.0),
                                        // TODO Profile Image
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Profile Image',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                color: pickUploadImageTextColor,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _pickImage(
                                                ImageSource.gallery,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration:
                                                    bodyCircularItemsDecoration(),
                                                child: Icon(
                                                    Icons.add_a_photo_outlined),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// TODO SignUp Button
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(15.0, 20.0, 15, 0.0),
                                  child: GestureDetector(
                                    onTap: () => signUpMethod(),
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
                                              Text('Register',
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

                                /// TODO Already have an account
                                Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Already have an account ? ',
                                          style: simpleTextStyle()),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage()));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Login',
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
                                SizedBox(height: 10.0)
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
