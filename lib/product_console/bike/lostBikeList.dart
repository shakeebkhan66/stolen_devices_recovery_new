import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stolen_devices_recovery/product_console/bike/searchLostBike.dart';
import 'package:stolen_devices_recovery/services/database.dart';
import 'package:stolen_devices_recovery/shared/widgets.dart';

// ignore: must_be_immutable
class LostBikeList extends StatefulWidget {
  @override
  _LostBikeListState createState() => _LostBikeListState();
}

class _LostBikeListState extends State<LostBikeList> {
  /// Display Lost Mobile Image with Data
  void displayLostMobileImageWithData(String bikeName, String bikeVIN,
      String bikeContact, String bikePurDate, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: alertDialogColor,
          shape: shapeTwentyCircular(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $bikeName", style: viewOutputAlertDialogTextStyle()),
              Text("IMEI No: $bikeVIN",
                  style: viewOutputAlertDialogTextStyle()),
              Text("Contact No: $bikeContact",
                  style: viewOutputAlertDialogTextStyle()),
              Text("Purchasing Date: $bikePurDate",
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
      appBar: appBarMain("Lost Mobile List"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan[700],
        elevation: 10.0,
        child: Icon(Icons.saved_search_outlined,
            color: insideFloatingButtonIconColor, size: 30.0),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SearchLostBike()));
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Column(
              children: [
                /// Stream Builder
                StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().fetchLostBikeData(),
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
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xff0b0704),
                                        child: Icon(Icons.update_outlined,
                                            color: Colors.grey),
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
                                              displayLostMobileImageWithData(
                                                ds["Lost_Bike_Name"],
                                                ds["Lost_Bike_VIN"],
                                                ds["Lost_Bike_Contact"],
                                                ds["Lost_Bike_PurDate"]
                                                    .toString()
                                                    .split(" ")
                                                    .first,
                                                ds["Lost_Bike_Image_Url"],
                                              );
                                            },
                                          ),
                                          Text(
                                            ds["Lost_Bike_PurDate"]
                                                .toString()
                                                .split(" ")
                                                .first,
                                            textAlign: TextAlign.center,
                                            style:
                                                outputListTileDateTextStyle(),
                                          ),
                                        ],
                                      ),

                                      /// Name
                                      title: Text(
                                        ds["Lost_Bike_Name"],
                                        style: outputListTileNameTextStyle(),
                                      ),

                                      /// IMEI
                                      subtitle: Text(
                                        ds["Lost_Bike_VIN"],
                                        style: outputListTileIMEITextStyle(),
                                      ),
                                    ),
                                  ),
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
          ),
        ),
      ),
    );
  }
}
