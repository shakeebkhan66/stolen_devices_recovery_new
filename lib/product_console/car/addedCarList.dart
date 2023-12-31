import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stolen_devices_recovery/product_console/car/searchAddedCar.dart';
import 'package:stolen_devices_recovery/services/database.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';

// ignore: must_be_immutable
class AddedCarList extends StatefulWidget {
  String ds;
  AddedCarList({required this.ds});

  @override
  _AddedCarListState createState() => _AddedCarListState();
}

class _AddedCarListState extends State<AddedCarList> {
  /// Variables
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController carNameController = new TextEditingController();
  TextEditingController carVINController = new TextEditingController();
  TextEditingController userPhoneController = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? imageSnap;
  DateTime? _dateTime;
  bool isLoading = false;

  /// Active image file
  XFile? _imageFile;

  /// Update an image via gallery
  Future _pickImage(ImageSource source) async {
    XFile? selected = await ImagePicker().pickImage(source: source);
    setState(() {
      _imageFile = selected;
    });
  }

  /// Update to Firebase
  Future _uploadImage() async {
    final file = File(_imageFile!.path);
    final destination = "Car_Images/${DateTime.now()}.png";
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
            colorScheme: ColorScheme.light(primary: Colors.teal),
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

  /// Update Mobile Data Method
  void updateBikeData(BuildContext context, DocumentSnapshot ds) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xff282e54),
            shape: shapeTwentyCircular(),
            title: Text('Update Car Record !!',
                style: TextStyle(fontSize: 20.0, color: Color(0xffFFC069))),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  /// Form
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        /// Name
                        TextFormField(
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration(
                            'Enter Car Name',
                            Icon(Icons.drive_eta_outlined,
                                color: fieldIconColor),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          controller: carNameController,
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
                            'Enter Car VIN No',
                            Icon(Icons.drive_eta_outlined,
                                color: fieldIconColor),
                          ),
                          controller: carVINController,
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
                            'PHONE',
                            Icon(Icons.phone, color: fieldIconColor),
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
                      ],
                    ),
                  ),

                  /// Pick Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Purchasing Date',
                        style: simpleTextStyle(),
                      ),
                      IconButton(
                        onPressed: () => _pickDate(context),
                        icon: Icon(Icons.date_range_outlined),
                        color: pickDateIconColor,
                      ),
                    ],
                  ),

                  /// Show Picked Date
                  // Center(
                  //   child: Text(
                  //     _dateTime != null
                  //         // ? "${_dateTime.month}/${_dateTime.day}/${_dateTime.year}"
                  //         ? DateFormat('yyyy-MM-dd').format(_dateTime)
                  //         : "View Picked Date",
                  //     style: viewPickedDateTextStyle(),
                  //   ),
                  // ),
                  SizedBox(height: 20.0),

                  /// Add and Upload Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Image', style: simpleTextStyle()),
                      SizedBox(width: 25.0),
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: bodyCircularItemsDecoration(),
                          child: Icon(Icons.add_a_photo_outlined),
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
                ],
              ),
            ),

            /// Update Data to Firebase
            actions: [
              // ignore: deprecated_member_use
              TextButton.icon(
                style: TextButton.styleFrom(
                  shape: shapeFiftyCircular(),
                  backgroundColor: Colors.teal,
                ),
                label: Text("Update", style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.update_outlined, color: Colors.white),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (imageSnap != null) {
                      DocumentReference documentReference = FirebaseFirestore
                          .instance
                          .collection("SDRA_Users_Data")
                          .doc(_auth.currentUser?.email)
                          .collection("Bike_Data")
                          .doc(ds.id);

                      /// create Map to update data in key:value pair form
                      Map<String, dynamic> mobileData = ({
                        "Car_Name": carNameController.text,
                        "Car_VIN": carVINController.text,
                        "Car_Contact": userPhoneController.text,
                        "Car_PurDate": _dateTime.toString(),
                        "Car_Image_Url": imageSnap,
                        "Time": DateTime.now(),
                      });

                      /// update data to Firebase
                      documentReference.update(mobileData);
                      showToaster("Data updated successfully");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddedCarList(ds: '',)));
                    } else {
                      showToaster("Upload image first");
                    }
                  } else {
                    showToaster("Enter data first");
                  }
                },
              )
            ],
          );
        });
  }

  /// Add to lost Mobile list
  void addToLostCarList(BuildContext context, DocumentSnapshot ds) {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("SDRA_Users_Data")
          .doc(_auth.currentUser?.email)
          .collection("Lost_Car_Data")
          .doc(ds.id);

      /// create Map to send lost data
      Map<String, dynamic> lostCarData = ({
        "Lost_Car_Name": ds["Car_Name"],
        "Lost_Car_VIN": ds["Car_VIN"],
        "Lost_Car_Contact": ds["Car_Contact"],
        "Lost_Car_PurDate": ds["Car_PurDate"],
        "Lost_Car_Image_Url": ds["Car_Image_Url"],
        "Added_Car_Time": ds["Time"],
        "Time": DateTime.now(),
      });

      /// send Lost data to Firebase
      documentReference.set(lostCarData).whenComplete(() {
        /// TODO create separate lost bike list
        DocumentReference docReference =
            FirebaseFirestore.instance.collection("Lost_Car_Data").doc(ds.id);

        /// create separate Map
        Map<String, dynamic> lostCarList = ({
          "Lost_Car_Name": ds["Car_Name"],
          "Lost_Car_VIN": ds["Car_VIN"],
          "Lost_Car_Contact": ds["Car_Contact"],
          "Lost_Car_PurDate": ds["Car_PurDate"],
          "Lost_Car_Image_Url": ds["Car_Image_Url"],
          "Added_Car_Time": ds["Time"],
          "Time": DateTime.now(),
        });

        /// set separate lost mobile list
        docReference.set(lostCarList).whenComplete(() async {
          await FirebaseFirestore.instance
              .collection("SDRA_Users_Data")
              .doc(_auth.currentUser?.email)
              .collection("Car_Data")
              .doc(ds.id)
              .delete();
          showToaster("Data added successfully");
          Navigator.of(context).pop();
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  /// Display Mobile Image
  void displayCarImageWithData(String carName, String carVIN, String carContact,
      String carPurDate, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: alertDialogColor,
          shape: shapeTwentyCircular(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $carName", style: viewOutputAlertDialogTextStyle()),
              Text("VIN No: $carVIN", style: viewOutputAlertDialogTextStyle()),
              Text("Contact No: $carContact",
                  style: viewOutputAlertDialogTextStyle()),
              Text("Purchasing Date: $carPurDate",
                  style: viewOutputAlertDialogTextStyle()),
            ],
          ),
          content: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5,
            child: Image.network(imageUrl, fit: BoxFit.fill),
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.black,
              shape: shapeFiftyCircular(),
              child: Text('Ok', style: viewOutputAlertDialogButtonTextStyle()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain("Added Car List"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: floatingButtonColor,
        elevation: 10.0,
        child: Icon(Icons.saved_search_outlined,
            color: insideFloatingButtonIconColor, size: 30.0),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchCar()));
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.only(left: 6.0, right: 6.0, top: 10.0),
          child: Column(
            children: [
              // TODO Stream Builder
              StreamBuilder<QuerySnapshot>(
                stream: DatabaseService().fetchCarData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data!.docs[index];
                          return Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: shapeTwentyCircular(),
                                  color: alertDialogColor,
                                  child: ListTile(
                                    /// Update
                                    leading: GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xff0b0704),
                                        child: Icon(
                                          Icons.update_outlined,
                                          color: Colors.yellow[700],
                                        ),
                                      ),
                                      onTap: () => updateBikeData(context, ds),
                                    ),

                                    /// Date
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          child: Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.black,
                                            size: 30.0,
                                          ),
                                          onTap: () {
                                            displayCarImageWithData(
                                              ds["Car_Name"],
                                              ds["Car_VIN"],
                                              ds["Car_Contact"],
                                              ds["Car_PurDate"]
                                                  .toString()
                                                  .split(" ")
                                                  .first,
                                              ds["Car_Image_Url"],
                                            );
                                          },
                                        ),
                                        Text(
                                          ds["Car_PurDate"]
                                              .toString()
                                              .split(" ")
                                              .first,
                                          textAlign: TextAlign.center,
                                          style: outputListTileDateTextStyle(),
                                        ),
                                      ],
                                    ),

                                    /// Name
                                    title: Text(
                                      ds["Car_Name"],
                                      style: outputListTileNameTextStyle(),
                                    ),

                                    /// VIN
                                    subtitle: Text(
                                      ds["Car_VIN"],
                                      style: outputListTileIMEITextStyle(),
                                    ),
                                  ),
                                ),
                              ),

                              /// TODO Add to Lost Devices Icon
                              GestureDetector(
                                // Icon
                                child: Icon(Icons.add_circle_outline,
                                    color: addToLostListIconColor, size: 30.0),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.grey[300],
                                          shape: shapeTwentyCircular(),
                                          title: Text("Confirm your choice"),
                                          content: Text(
                                            "You are going to add this "
                                            "data to Lost Devices List. "
                                            "Are you sure ?"
                                            "\n\nAction can't be undo !!",
                                            textAlign: TextAlign.justify,
                                          ),
                                          actions: [
                                            // ignore: deprecated_member_use
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: TextButton.styleFrom(
                                                shape: shapeFiftyCircular(),
                                                backgroundColor: Colors.black,
                                              ),
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            // ignore: deprecated_member_use
                                            TextButton(
                                              onPressed: () =>
                                                  addToLostCarList(context, ds),
                                              style: TextButton.styleFrom(
                                                shape: shapeFiftyCircular(),
                                                backgroundColor: Colors.black,
                                              ),
                                              child: Text("Add",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ],
                          );
                        });
                  } else {
                    return Align(
                      alignment: FractionalOffset.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                        color: Colors.yellow[700],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}
