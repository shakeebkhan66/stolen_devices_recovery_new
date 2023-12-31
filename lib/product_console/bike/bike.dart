import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stolen_devices_recovery/product_console/bike/addedBikeList.dart';
import 'package:stolen_devices_recovery/product_console/bike/lostBikeList.dart';
import 'package:stolen_devices_recovery/shared/loading.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';

// ignore: must_be_immutable
class BikePage extends StatefulWidget {
  @override
  _BikePageState createState() => _BikePageState();
}

class _BikePageState extends State<BikePage>
    with SingleTickerProviderStateMixin {
  /// Variables
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController bikeNameController = new TextEditingController();
  TextEditingController bikeVINController = new TextEditingController();
  TextEditingController userPhoneController = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? imageSnap;
  DateTime? _dateTime;
  bool isLoading = false;

  /// Active image file
  XFile? _imageFile;

  /// Select an image via gallery
  Future _pickImage(ImageSource source) async {
    XFile? selected = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
  }

  /// Upload to Firebase
  Future _uploadImage() async {
    final file = File(_imageFile!.path);
    final destination = "Bike_Images/${DateTime.now()}.png";
    if (_imageFile != null) {
      Reference reference = FirebaseStorage.instance
          .ref(_auth.currentUser?.email)
          .child(destination);
      UploadTask _uploadTask = reference.putFile(file);
      _uploadTask.whenComplete(() async {
        try {
          String uploadedImageUrl = await reference.getDownloadURL();
          imageSnap = uploadedImageUrl;
          showToaster("Image uploaded successfully");
          print("This is URL: $imageSnap");
        } catch (e) {
          print(e.toString());
        }
      });
    } else {
      showToaster("Grant Permission and try again !");
      Navigator.of(context).pop();
    }
  }

  /// Pick Date
  Future _pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: _dateTime ?? initialDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.teal.shade700),
            // color of the text in the button "OK/CANCEL"
            // buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (newDate != null) {
      setState(() => _dateTime = newDate);
    }
  }

  /// Create Mobile Data Method
  createBikeData() async {
    try {
      if (formKey.currentState!.validate()) {
        setState(() => isLoading = true);
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection("SDRA_Users_Data")
            .doc(_auth.currentUser?.email)
            .collection("Bike_Data")
            .doc();

        /// create Map to send data in key:value pair form
        Map<String, dynamic> mobileData = ({
          "Bike_Name": bikeNameController.text,
          "Bike_VIN": bikeVINController.text,
          "Bike_Contact": userPhoneController.text,
          "Bike_PurDate": _dateTime.toString(),
          "Bike_Image_Url": imageSnap,
          "Time": DateTime.now(),
        });

        /// send data to Firebase
        documentReference.set(mobileData).whenComplete(() {
          showToaster("Data uploaded successfully");
          bikeNameController.clear();
          bikeVINController.clear();
          userPhoneController.clear();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BikePage()));
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Loading();
    } else {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: stackTopLeftCornerIconDecoration(),
                    child: Center(
                      child: Icon(Icons.directions_bike_outlined, size: 50.0),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 80.0),
                  child: Column(
                    children: [
                      // TODO Form
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            /// Name
                            TextFormField(
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration(
                                'Enter Bike Name',
                                Icon(Icons.directions_bike_outlined,
                                    color: fieldIconColor),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              controller: bikeNameController,
                              validator: (val) {
                                return val!.isEmpty || val.length > 16
                                    ? 'Name can\'t be longer than 15 characters'
                                    : null;
                              },
                            ),
                            SizedBox(height: 10.0),

                            /// VIN
                            TextFormField(
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration(
                                'Enter Bike VIN No',
                                Icon(Icons.directions_bike_outlined,
                                    color: fieldIconColor),
                              ),
                              controller: bikeVINController,
                              validator: (val) {
                                return val!.isEmpty || val.length != 17
                                    ? 'Enter 17 characters VIN number'
                                    : null;
                              },
                            ),
                            SizedBox(height: 10.0),

                            /// Phone
                            TextFormField(
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration(
                                'Enter Contact No',
                                Icon(Icons.phone, color: fieldIconColor),
                              ),
                              controller: userPhoneController,
                              validator: (val) {
                                return RegExp(
                                  // "^(?:[+0]9)?[0-9]{10,12}",
                                  "^[0-9]{4} [0-9]{7}",
                                ).hasMatch(val!)
                                    ? null
                                    : 'Format XXXX XXXXXXX';
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      // TODO Pick Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Bike Purchasing Date',
                            style: simpleTextStyle(),
                          ),
                          IconButton(
                            onPressed: () => _pickDate(context),
                            icon: Icon(Icons.date_range_outlined),
                            color: pickDateIconColor,
                          ),
                        ],
                      ),
                      // TODO Show Picked Date
                      Center(
                        child: Text(
                          _dateTime != null
                              // ? "${_dateTime.month}/${_dateTime.day}/${_dateTime.year}"
                              ? DateFormat('yyyy-MM-dd').format(_dateTime!)
                              : "View Picked Date",
                          style: viewPickedDateTextStyle(),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      // TODO Add Image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pick Image',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: pickUploadImageTextColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: bodyCircularItemsDecoration(),
                              child: Icon(Icons.add_a_photo_outlined),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      // TODO Upload Image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upload Image',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: pickUploadImageTextColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _uploadImage(),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: bodyCircularItemsDecoration(),
                              child: Icon(Icons.cloud_upload_outlined),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 100.0),
                      // TODO Add Button
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () => formKey.currentState!.validate()
                                  ? imageSnap != null
                                      ? createBikeData()
                                      : showToaster("Upload image first")
                                  : showToaster("Enter data first"),
                              color: buttonColor,
                              shape: shapeFiftyCircular(),
                              child: Text('ADD', style: simpleTextStyle()),
                            ),
                          ),
                        ],
                      ),
                      // TODO View Button
                      Row(
                        children: [
                          /// Added List Button
                          Expanded(
                            child: MaterialButton(
                              color: addedLostListButtonColor,
                              shape: shapeFiftyCircular(),
                              child: Text('Added List',
                                  style: textInsideButtonStyle()),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddedBikeList(ds: '',)));
                              },
                            ),
                          ),
                          SizedBox(width: 10.0),

                          /// Lost List Button
                          Expanded(
                            child: MaterialButton(
                              color: addedLostListButtonColor,
                              shape: shapeFiftyCircular(),
                              child: Text('Lost List',
                                  style: textInsideButtonStyle()),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LostBikeList()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
