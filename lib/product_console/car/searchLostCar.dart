import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';
import 'package:flutter/material.dart';

class SearchLostCar extends StatefulWidget {
  @override
  _SearchLostCarState createState() => _SearchLostCarState();
}

class _SearchLostCarState extends State<SearchLostCar> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  TextEditingController searchLostBikeController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Search Bike Data from Firebase
  Map<String, dynamic>? searchedLostBikeMap;
  void searchBikeData() async {
    formKey.currentState!.validate()
        ? await FirebaseFirestore.instance
            .collection("SDRA_Users_Data")
            .doc(_auth.currentUser?.email)
            .collection("Lost_Car_Data")
            .where("Lost_Car_VIN", isEqualTo: searchLostBikeController.text)
            .get()
            .then((result) {
            setState(() => searchedLostBikeMap = result.docs[0].data());
            print(searchedLostBikeMap);
          })
        : showToaster("Enter VIN first");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Form
              Container(
                color: searchBarColor,
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration(
                            'Search by VIN...',
                            Icon(Icons.directions_bike_outlined,
                                color: Colors.grey),
                          ),
                          controller: searchLostBikeController,
                          validator: (val) {
                            return val!.isEmpty || val.length != 17
                                ? 'Enter 17 characters VIN number'
                                : null;
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => searchBikeData(),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: bodyCircularItemsDecoration(),
                        child: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child:
                    Divider(thickness: 1.0, height: 20.0, color: Colors.green),
              ),

              /// Display Searched Data
              Padding(
                padding: EdgeInsets.all(10.0),
                child: searchedLostBikeMap != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name: " + searchedLostBikeMap?["Lost_Car_Name"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          Text(
                            "VIN No: " + searchedLostBikeMap?["Lost_Car_VIN"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          Text(
                            "Contact No: " +
                                searchedLostBikeMap?["Lost_Car_Contact"],
                            style: searchedDataOutputTextStyle(),
                          ),
                          Text(
                            "Purchasing Date: " +
                                searchedLostBikeMap!["Lost_Car_PurDate"]
                                    .toString()
                                    .split(" ")
                                    .first,
                            style: searchedDataOutputTextStyle(),
                          ),
                          SizedBox(height: 20.0),
                          InteractiveViewer(
                            minScale: 0.1,
                            maxScale: 5,
                            child: Image.network(
                              searchedLostBikeMap?["Lost_Car_Image_Url"],
                            ),
                          ),
                        ],
                      )
                    : Text("Search data to view !!",
                        textAlign: TextAlign.center, style: simpleTextStyle()),
              ),

              /// Buttons
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                // ignore: deprecated_member_use
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    shape: shapeFiftyCircular(),
                    backgroundColor: Colors.cyan.shade700,
                  ),
                  label: Text('Refresh', style: simpleTextStyle()),
                  icon: Icon(Icons.refresh_outlined, color: Colors.white),
                  onPressed: () => setState(() {
                    searchLostBikeController.clear();
                    searchedLostBikeMap = null;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
