import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stolen_devices_recovery/screens/signIn.dart';
import 'package:stolen_devices_recovery/screens/signUp.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController searchMobileController = new TextEditingController();
  TextEditingController searchBikeController = new TextEditingController();
  TextEditingController searchCarController = new TextEditingController();
  String selectedRadioText = "Mobile";
  Map<String, dynamic>? searchedLostDeviceMap;

  // TODO Radio Function
  setSelectedRadio(value) => setState(() => selectedRadioText = value);

  /// TODO Search TextFields
  // Widget textFieldType() {
  //   if (selectedRadioText == "Bike") {
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: Form(
  //             key: _formKey,
  //             child: TextFormField(
  //               style: simpleTextStyle(),
  //               decoration: homePageTextFieldInputDecoration(
  //                 'Check lost bike by VIN',
  //                 Icon(Icons.directions_bike_outlined, color: Colors.black54),
  //               ),
  //               controller: searchBikeController,
  //               validator: (val) {
  //                 return val.isEmpty || val.length != 17
  //                     ? 'Enter 17 characters VIN number'
  //                     : null;
  //               },
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 8.0),
  //         // GestureDetector(
  //         //   onTap: () => displayLostBikeData(),
  //         //   child: Container(
  //         //     padding: EdgeInsets.all(10),
  //         //     decoration: adminSignInPageButtonDecoration(),
  //         //     child: Icon(Icons.search, color: homePageIconInsideButtonColors),
  //         //   ),
  //         // ),
  //       ],
  //     );
  //   } else if (selectedRadioText == "Car") {
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: Form(
  //             key: _formKey,
  //             child: TextFormField(
  //               style: simpleTextStyle(),
  //               decoration: homePageTextFieldInputDecoration(
  //                 'Check lost car by VIN',
  //                 Icon(Icons.drive_eta_outlined, color: Colors.black54),
  //               ),
  //               controller: searchCarController,
  //               validator: (val) {
  //                 return val.isEmpty || val.length != 17
  //                     ? 'Enter 17 characters VIN number'
  //                     : null;
  //               },
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 8.0),
  //         // GestureDetector(
  //         //   onTap: () => displayLostCarData(),
  //         //   child: Container(
  //         //     padding: EdgeInsets.all(10),
  //         //     decoration: adminSignInPageButtonDecoration(),
  //         //     child: Icon(Icons.search, color: homePageIconInsideButtonColors),
  //         //   ),
  //         // ),
  //       ],
  //     );
  //   } else {
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: Form(
  //             key: _formKey,
  //             child: TextFormField(
  //               style: simpleTextStyle(),
  //               keyboardType: TextInputType.number,
  //               decoration: homePageTextFieldInputDecoration(
  //                 'Check lost mobile by IMEI',
  //                 Icon(Icons.phone_android_outlined, color: Colors.black54),
  //               ),
  //               controller: searchMobileController,
  //               validator: (val) {
  //                 return val.isEmpty || val.length != 15
  //                     ? 'Enter 15-digit IMEI number'
  //                     : null;
  //               },
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 8.0),
  //         GestureDetector(
  //           onTap: () => displayLostMobileData(),
  //           child: Container(
  //             padding: EdgeInsets.all(10),
  //             decoration: adminSignInPageButtonDecoration(),
  //             child: Icon(Icons.search, color: homePageIconInsideButtonColors),
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  // }

  // ignore: missing_return
  Widget? textFieldType() {
    if (selectedRadioText == "Mobile") {
      return Row(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: TextFormField(
                style: simpleTextStyle(),
                keyboardType: TextInputType.number,
                decoration: homePageTextFieldInputDecoration(
                  'Check lost mobile by IMEI',
                  Icon(Icons.phone_android_outlined, color: Colors.black54),
                ),
                controller: searchMobileController,
                validator: (val) {
                  return val!.isEmpty || val.length != 15
                      ? 'Enter 15-digit IMEI number'
                      : null;
                },
              ),
            ),
          ),
          SizedBox(width: 8.0),
          GestureDetector(
            onTap: () => displayLostMobileData(),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: adminSignInPageButtonDecoration(),
              child: Icon(Icons.search, color: homePageIconInsideButtonColors),
            ),
          ),
        ],
      );
    }
  }

  /// Display Lost Bike Data
  // void displayLostBikeData() async {
  //   if (_formKey.currentState.validate()) {
  //     await FirebaseFirestore.instance
  //         .collection("Lost_Bike_Data")
  //         .where("Lost_Bike_VIN", isEqualTo: searchBikeController.text)
  //         .get()
  //         .then((result) async {
  //       setState(() => searchedLostDeviceMap = result.docs[0].data());
  //       // print(searchedLostMobileMap);
  //     });
  //   } else {
  //     showToaster("Enter VIN first");
  //   }
  // }

  /// Display Lost Car Data
  // void displayLostCarData() async {
  //   if (_formKey.currentState.validate()) {
  //     await FirebaseFirestore.instance
  //         .collection("Lost_Car_Data")
  //         .where("Lost_Car_VIN", isEqualTo: searchCarController.text)
  //         .get()
  //         .then((result) {
  //       setState(() => searchedLostDeviceMap = result.docs[0].data());
  //       // print(searchedLostMobileMap);
  //     });
  //   } else {
  //     showToaster("Enter VIN first");
  //   }
  // }

  /// Display Lost Mobile Data
  void displayLostMobileData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection("Lost_Mobile_Data")
          .where("Lost_Mobile_IMEI", isEqualTo: searchMobileController.text)
          .get()
          .then((result) {
        setState(() => searchedLostDeviceMap = result.docs[0].data());
        // print(searchedLostMobileMap);
      });
    } else {
      showToaster("Enter IMEI first");
    }
  }

  /// Call
  void launchCall(String phoneNumber) async {
    String url = "tel:" + phoneNumber;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print(' Could not launch $url');
    }
  }

  /// SMS
  // String message = "This is text message!";
  // List<String> recipents = ["9876543210", "8765432190"];

  void launchSMS(String message, String phoneNumber) async {
    String url = "sms:" + phoneNumber;
    if (await canLaunch(url)) {
      _sendSMS(message, phoneNumber.split(":").toList());
    } else {
      print(' Could not launch $url');
    }
  }

  void _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              /// TODO Background UI
              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                decoration: adminSignInPageBackgroundDecoration(),
              ),

              /// TODO Register Button
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    height: 40.0,
                    decoration: adminSignInPageButtonDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Register',
                            style: homePageTextInsideButtonStyle()),
                        Icon(Icons.arrow_forward,
                            color: homePageIconInsideButtonColors),
                      ],
                    ),
                  ),
                ),
              ),

              /// TODO Login Button
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 60.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    height: 40.0,
                    decoration: adminSignInPageButtonDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Login', style: homePageTextInsideButtonStyle()),
                        Icon(Icons.arrow_forward,
                            color: homePageIconInsideButtonColors),
                      ],
                    ),
                  ),
                ),
              ),

              // /// TODO Admin Button
              // Container(
              //   padding: EdgeInsets.only(left: 230.0, right: 15.0, top: 10.0),
              //   alignment: Alignment.centerRight,
              //   child: Container(
              //     decoration: adminSignInPageButtonDecoration(),
              //     child: GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => BackgroundUI()));
              //       },
              //       child: Container(
              //         padding: EdgeInsets.symmetric(horizontal: 25.0),
              //         height: 40.0,
              //         decoration: adminSignInPageButtonDecoration(),
              //         child: Icon(Icons.admin_panel_settings,
              //             color: homePageIconInsideButtonColors),
              //       ),
              //     ),
              //   ),
              // ),
              //
              // /// TODO Refresh Button
              // Container(
              //   padding: EdgeInsets.only(left: 230.0, right: 15.0, top: 60.0),
              //   alignment: Alignment.centerRight,
              //   child: Container(
              //     decoration: adminSignInPageButtonDecoration(),
              //     child: GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           searchBikeController.clear();
              //           searchCarController.clear();
              //           searchMobileController.clear();
              //           searchedLostDeviceMap = null;
              //         });
              //       },
              //       child: Container(
              //         padding: EdgeInsets.symmetric(horizontal: 25.0),
              //         height: 40.0,
              //         decoration: adminSignInPageButtonDecoration(),
              //         child: Icon(Icons.refresh_outlined,
              //             color: homePageIconInsideButtonColors),
              //       ),
              //     ),
              //   ),
              // ),

              /// TODO Radio Button
              Padding(
                padding: EdgeInsets.only(left: 40.0, right: 15.0, top: 115.0),
                child: Row(
                  children: <Widget>[
                    /// Mobile
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Radio(
                            key: UniqueKey(),
                            value: "Mobile",
                            groupValue: selectedRadioText,
                            activeColor: activeRadioButtonColor,
                            onChanged: (val) {
                              searchBikeController.clear();
                              searchCarController.clear();
                              searchMobileController.clear();
                              searchedLostDeviceMap = null;
                              setSelectedRadio(val);
                            },
                          ),
                          // Text('Mobile', style: simpleTextStyle()),
                          Icon(Icons.phone_android_outlined,
                              color: homePageRadioButtonIconColors),
                        ],
                      ),
                    ),

                    /// Bike
                    // Expanded(
                    //   child: Row(
                    //     children: <Widget>[
                    //       Radio(
                    //         key: UniqueKey(),
                    //         value: "Bike",
                    //         groupValue: selectedRadioText,
                    //         activeColor: activeRadioButtonColor,
                    //         onChanged: (val) {
                    //           searchBikeController.clear();
                    //           searchCarController.clear();
                    //           searchMobileController.clear();
                    //           searchedLostDeviceMap = null;
                    //           setSelectedRadio(val);
                    //         },
                    //       ),
                    //       // Text('Bike', style: simpleTextStyle()),
                    //       Icon(Icons.directions_bike_outlined,
                    //           color: homePageRadioButtonIconColors),
                    //     ],
                    //   ),
                    // ),
                    //
                    // /// Car
                    // Expanded(
                    //   child: Row(
                    //     children: <Widget>[
                    //       Radio(
                    //         key: UniqueKey(),
                    //         value: "Car",
                    //         groupValue: selectedRadioText,
                    //         activeColor: activeRadioButtonColor,
                    //         onChanged: (val) {
                    //           searchBikeController.clear();
                    //           searchCarController.clear();
                    //           searchMobileController.clear();
                    //           searchedLostDeviceMap = null;
                    //           setSelectedRadio(val);
                    //         },
                    //       ),
                    //       // Text('Car', style: simpleTextStyle()),
                    //       Icon(Icons.drive_eta_outlined,
                    //           color: homePageRadioButtonIconColors)
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),

              /// TODO TextField
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 15.0, top: 155.0),
                child: textFieldType(),
              ),

              /// TODO Display Data
              // Padding(
              //   padding: EdgeInsets.only(top: 300.0, left: 15.0, right: 15.0),
              //   child: searchedLostDeviceMap != null
              //       ? selectedRadioText == "Bike"
              //           ? Column(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: [
              //                 /// Name
              //                 Text(
              //                   "Name: " +
              //                       searchedLostDeviceMap["Lost_Bike_Name"],
              //                   style: searchedDataOutputTextStyle(),
              //                 ),
              //                 SizedBox(height: 5.0),
              //
              //                 /// VIN
              //                 Text(
              //                   "VIN: " +
              //                       searchedLostDeviceMap["Lost_Bike_VIN"],
              //                   style: searchedDataOutputTextStyle(),
              //                 ),
              //                 SizedBox(height: 5.0),
              //
              //                 /// PurDate
              //                 Text(
              //                   "Purchasing Date: " +
              //                       searchedLostDeviceMap["Lost_Bike_PurDate"]
              //                           .toString()
              //                           .split(" ")
              //                           .first,
              //                   style: searchedDataOutputTextStyle(),
              //                 ),
              //                 SizedBox(height: 5.0),
              //
              //                 /// Contact
              //                 Text(
              //                   "Contact: " +
              //                       searchedLostDeviceMap["Lost_Bike_Contact"],
              //                   style: searchedDataOutputTextStyle(),
              //                 ),
              //                 SizedBox(height: 5.0),
              //
              //                 /// Call and SMS
              //                 Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceEvenly,
              //                   children: [
              //                     // ignore: deprecated_member_use
              //                     FlatButton.icon(
              //                       onPressed: () => launchCall(
              //                         searchedLostDeviceMap["Lost_Bike_Contact"]
              //                             .toString(),
              //                       ),
              //                       color: Colors.green[700],
              //                       shape: shapeTwentyCircular(),
              //                       label: Text("Call",
              //                           style: homePageTextInsideButtonStyle()),
              //                       icon:
              //                           Icon(Icons.phone, color: Colors.white),
              //                     ),
              //                     // ignore: deprecated_member_use
              //                     FlatButton.icon(
              //                       onPressed: () => launchSMS(
              //                         "Your bike has been lost",
              //                         searchedLostDeviceMap["Lost_Bike_Contact"]
              //                             .toString(),
              //                       ),
              //                       color: Colors.blue[700],
              //                       shape: shapeTwentyCircular(),
              //                       label: Text("SMS",
              //                           style: homePageTextInsideButtonStyle()),
              //                       icon: Icon(Icons.sms, color: Colors.white),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(height: 20.0),
              //
              //                 /// Image
              //                 InteractiveViewer(
              //                   minScale: 0.1,
              //                   maxScale: 5,
              //                   child: Image.network(
              //                     searchedLostDeviceMap["Lost_Bike_Image_Url"],
              //                     fit: BoxFit.fill,
              //                   ),
              //                 ),
              //               ],
              //             )
              //           : selectedRadioText == "Car"
              //               ? Column(
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     /// Name
              //                     Text(
              //                       "Name: " +
              //                           searchedLostDeviceMap["Lost_Car_Name"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// VIN
              //                     Text(
              //                       "VIN: " +
              //                           searchedLostDeviceMap["Lost_Car_VIN"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// PurDate
              //                     Text(
              //                       "Purchasing Date: " +
              //                           searchedLostDeviceMap[
              //                                   "Lost_Car_PurDate"]
              //                               .toString()
              //                               .split(" ")
              //                               .first,
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// Contact
              //                     Text(
              //                       "Contact: " +
              //                           searchedLostDeviceMap[
              //                               "Lost_Car_Contact"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// Call and SMS
              //                     Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceEvenly,
              //                       children: [
              //                         // ignore: deprecated_member_use
              //                         FlatButton.icon(
              //                           onPressed: () => launchCall(
              //                             searchedLostDeviceMap[
              //                                     "Lost_Car_Contact"]
              //                                 .toString(),
              //                           ),
              //                           color: Colors.green[700],
              //                           shape: shapeTwentyCircular(),
              //                           label: Text('Call',
              //                               style: simpleTextStyle()),
              //                           icon: Icon(Icons.phone,
              //                               color: Colors.white),
              //                         ),
              //                         // ignore: deprecated_member_use
              //                         FlatButton.icon(
              //                           onPressed: () => launchSMS(
              //                             "Your car has been lost",
              //                             searchedLostDeviceMap[
              //                                     "Lost_Car_Contact"]
              //                                 .toString(),
              //                           ),
              //                           color: Colors.blue[700],
              //                           shape: shapeTwentyCircular(),
              //                           label: Text("SMS",
              //                               style:
              //                                   homePageTextInsideButtonStyle()),
              //                           icon: Icon(Icons.sms,
              //                               color: Colors.white),
              //                         ),
              //                       ],
              //                     ),
              //                     SizedBox(height: 20.0),
              //
              //                     /// Image
              //                     InteractiveViewer(
              //                       minScale: 0.1,
              //                       maxScale: 5,
              //                       child: Image.network(
              //                         searchedLostDeviceMap[
              //                             "Lost_Car_Image_Url"],
              //                         fit: BoxFit.fill,
              //                       ),
              //                     ),
              //                   ],
              //                 )
              //               : Column(
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     /// Name
              //                     Text(
              //                       "Name: " +
              //                           searchedLostDeviceMap[
              //                               "Lost_Mobile_Name"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// IMEI
              //                     Text(
              //                       "IMEI: " +
              //                           searchedLostDeviceMap[
              //                               "Lost_Mobile_IMEI"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// PurDate
              //                     Text(
              //                       "Purchasing Date: " +
              //                           searchedLostDeviceMap[
              //                                   "Lost_Mobile_PurDate"]
              //                               .toString()
              //                               .split(" ")
              //                               .first,
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// Contact
              //                     Text(
              //                       "Contact: " +
              //                           searchedLostDeviceMap[
              //                               "Lost_Mobile_Contact"],
              //                       style: searchedDataOutputTextStyle(),
              //                     ),
              //                     SizedBox(height: 5.0),
              //
              //                     /// Call and SMS
              //                     Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceEvenly,
              //                       children: [
              //                         // ignore: deprecated_member_use
              //                         FlatButton.icon(
              //                           onPressed: () => launchCall(
              //                             searchedLostDeviceMap[
              //                                     "Lost_Mobile_Contact"]
              //                                 .toString(),
              //                           ),
              //                           color: Colors.green[700],
              //                           shape: shapeTwentyCircular(),
              //                           label: Text('Call',
              //                               style: simpleTextStyle()),
              //                           icon: Icon(Icons.phone,
              //                               color: Colors.white),
              //                         ),
              //                         // ignore: deprecated_member_use
              //                         FlatButton.icon(
              //                           onPressed: () => launchSMS(
              //                             "Your mobile has been lost",
              //                             searchedLostDeviceMap[
              //                                     "Lost_Mobile_Contact"]
              //                                 .toString(),
              //                           ),
              //                           color: Colors.blue[700],
              //                           shape: shapeTwentyCircular(),
              //                           label: Text("SMS",
              //                               style:
              //                                   homePageTextInsideButtonStyle()),
              //                           icon: Icon(Icons.sms,
              //                               color: Colors.white),
              //                         ),
              //                       ],
              //                     ),
              //                     SizedBox(height: 20.0),
              //
              //                     /// Image
              //                     InteractiveViewer(
              //                       minScale: 0.1,
              //                       maxScale: 5,
              //                       child: Image.network(
              //                         searchedLostDeviceMap[
              //                             "Lost_Mobile_Image_Url"],
              //                         fit: BoxFit.fill,
              //                       ),
              //                     ),
              //                   ],
              //                 )
              //       : Container(
              //           padding: EdgeInsets.only(top: 150.0),
              //           alignment: Alignment.center,
              //           child: Text(
              //             "Search...!!\nView Lost Data ",
              //             textAlign: TextAlign.center,
              //             style: simpleTextStyle(),
              //           ),
              //         ),
              // ),
              // TODO Display Data
              Padding(
                padding: EdgeInsets.only(top: 300.0, left: 15.0, right: 15.0),
                child: searchedLostDeviceMap != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Name
                          Text(
                            "Name: " +
                                searchedLostDeviceMap?["Lost_Mobile_Name"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          SizedBox(height: 5.0),

                          /// IMEI
                          Text(
                            "IMEI: " +
                                searchedLostDeviceMap?["Lost_Mobile_IMEI"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          SizedBox(height: 5.0),

                          /// PurDate
                          Text(
                            "Purchasing Date: " +
                                searchedLostDeviceMap!["Lost_Mobile_PurDate"]
                                    .toString()
                                    .split(" ")
                                    .first,
                            style: searchedDataOutputTextStyle(),
                          ),
                          SizedBox(height: 5.0),

                          /// Contact
                          Text(
                            "Contact: " +
                                searchedLostDeviceMap?["Lost_Mobile_Contact"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          SizedBox(height: 5.0),

                          /// Call and SMS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // ignore: deprecated_member_use
                              TextButton.icon(
                                onPressed: () => launchCall(
                                  searchedLostDeviceMap!["Lost_Mobile_Contact"]
                                      .toString(),
                                ),
                                style: TextButton.styleFrom(
                                  shape: shapeTwentyCircular(),
                                  backgroundColor: Colors.green,
                                ),
                                label: Text('Call', style: simpleTextStyle()),
                                icon: Icon(Icons.phone, color: Colors.white),
                              ),
                              // ignore: deprecated_member_use
                              TextButton.icon(
                                onPressed: () => launchSMS(
                                  "Your mobile has been lost",
                                  searchedLostDeviceMap!["Lost_Mobile_Contact"]
                                      .toString(),
                                ),
                                style: TextButton.styleFrom(
                                  shape: shapeTwentyCircular(),
                                  backgroundColor: Colors.blue,
                                ),
                                label: Text("SMS",
                                    style: homePageTextInsideButtonStyle()),
                                icon: Icon(Icons.sms, color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),

                          /// Image
                          InteractiveViewer(
                            minScale: 0.1,
                            maxScale: 5,
                            child: Image.network(
                              searchedLostDeviceMap?["Lost_Mobile_Image_Url"],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 150.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Search...!!\nView Lost Data ",
                          textAlign: TextAlign.center,
                          style: simpleTextStyle(),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: homePageBottomNavigationDecoration(),
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  searchBikeController.clear();
                  searchCarController.clear();
                  searchMobileController.clear();
                  searchedLostDeviceMap = null;
                });
              },
              child: Column(
                children: [
                  Icon(Icons.refresh, color: Color(0xffe1a300)),
                  Text("Refresh Page", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
