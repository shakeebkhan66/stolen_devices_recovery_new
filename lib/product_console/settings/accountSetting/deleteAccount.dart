import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stolen_devices_recovery/helper/helperFunctions.dart';
import 'package:stolen_devices_recovery/screens/after_splashScreen.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  /// Variables
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  FirebaseFirestore _user = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userAccountMap;
  bool _isObscure = true;

  /// Conform Choice
  void conformDelete(String email, String pwd) async {
    if (formKey.currentState!.validate()) {
      try {
        QuerySnapshot result = await _user
            .collection("SDRA_Users")
            .where("Email", isEqualTo: userEmailController.text)
            .get();

        if (result.docs.isNotEmpty) {
          setState(() => userAccountMap = result.docs[0].data() as Map<String, dynamic>);
          print(userAccountMap);

          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: pwd,
          );

          await _auth.currentUser?.reauthenticateWithCredential(credential);
          await _auth.currentUser?.delete();
          await HelperFunctions.saveUserLoggedInSharedPreference(false);

          DocumentReference userAccount =
          _user.collection('SDRA_Users').doc(email);
          await userAccount.delete();

          showToaster("Account deleted successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (error) {
        showToaster("Credentials Error");
      }
    } else {
      showToaster("Enter correct credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Warning tile
              ListTile(
                tileColor: Colors.red[700],
                shape: shapeFiftyCircular(),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Warning...!!", style: settingViewAccountTextStyle()),
                    Icon(Icons.warning, color: Colors.yellow),
                  ],
                ),
              ),

              /// Text
              Padding(
                padding: EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 50.0, bottom: 20.0),
                child: Text(
                  "Are you sure you want to delete your account permanently ?"
                      "\n\nIf you delete your account. "
                      "All of your credentials will be lost "
                      "and can't be recovered again...!!",
                  textAlign: TextAlign.justify,
                  style: settingDeleteAccountTextStyle(),
                ),
              ),

              /// Form
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // email
                      TextFormField(
                        style: simpleTextStyle(),
                        decoration: textFieldInputDecoration(
                          'EMAIL',
                          Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                        controller: userEmailController,
                        validator: (val) {
                          return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(val ?? "")
                              ? null
                              : "Valid email required";
                        },
                      ),
                      SizedBox(height: 10.0),
                      // password
                      TextFormField(
                        style: simpleTextStyle(),
                        obscureText: _isObscure,
                        decoration: passwordViewInputDecoration(
                          'PASSWORD',
                          Icon(Icons.vpn_key, color: Colors.grey),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isObscure = !_isObscure),
                            child: Icon(
                              _isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        controller: userPasswordController,
                        validator: (val) {
                          return val?.isEmpty ?? true || val!.length < 6
                              ? 'Minimum 6 characters required'
                              : null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.0),

              /// Conform and Cancel Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// Cancel
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      shape: shapeFiftyCircular(),
                    ),
                    icon: Icon(Icons.cancel_outlined, color: Colors.white),
                    label: Text(
                      "Return to page",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  /// Confirm
                  TextButton.icon(
                    onPressed: () => conformDelete(
                        userEmailController.text, userPasswordController.text),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      shape: shapeFiftyCircular(),
                    ),
                    icon: Icon(Icons.done_outline, color: Colors.white),
                    label: Text(
                      "Confirm Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 112.0),

              /// Logo
              Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/logo1.png'),
                  backgroundColor: Colors.transparent,
                  radius: 30.0,
                ),
              ),

              /// App Name
              Center(
                child: Text(
                  'Stolen Devices Recovery App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Monsterrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
