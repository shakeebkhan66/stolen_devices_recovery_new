// import 'dart:async';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:stolen_devices_recovery/shared/widgets.dart';
//
// /// Widget to capture and crop the image
// class MobileImage extends StatefulWidget {
//   createState() => _MobileImageState();
// }
//
// class _MobileImageState extends State<MobileImage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   // UploadTask _uploadTask;
//
//   /// Active image file
//   File _imageFile;
//
//   /// Cropper plugin
//   Future<void> _cropImage() async {
//     File cropped = await ImageCropper.cropImage(
//       sourcePath: _imageFile.path,
//       // ratioX: 1.0,
//       // ratioY: 1.0,
//       // maxWidth: 512,
//       // maxHeight: 512,
//       toolbarColor: Colors.teal[700],
//       toolbarWidgetColor: Colors.white,
//       toolbarTitle: 'Crop it',
//       statusBarColor: Colors.black,
//     );
//
//     setState(() {
//       _imageFile = cropped ?? _imageFile;
//     });
//   }
//
//   /// Select an image via gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     File selected = await ImagePicker.pickImage(source: source);
//     setState(() {
//       _imageFile = selected;
//     });
//   }
//
//   /// Upload to Firebase
//   Future _uploadImage() async {
//     final file = File(_imageFile.path);
//     final destination = "Mobile_Images/${DateTime.now()}.png";
//     if (_imageFile != null) {
//       Reference reference =
//           FirebaseStorage.instance.ref("SDRA_Images").child(destination);
//       UploadTask _uploadTask = reference.putFile(file);
//       _uploadTask.whenComplete(() async {
//         try {
//           String uploadedImageUrl = await reference.getDownloadURL();
//           print("This is URL: $uploadedImageUrl");
//
//           /// call fucntion
//           imageUrlSetToUserCollection(uploadedImageUrl);
//         } catch (e) {
//           print(e.toString());
//         }
//       });
//     } else {
//       showToaster("Grant Permission and try again !");
//       Navigator.of(context).pop();
//     }
//   }
//
//   /// Set Image URL to Cloud Firestore Collection
//   void imageUrlSetToUserCollection(String url) async {
//     DocumentReference documentReference = FirebaseFirestore.instance
//         .collection("SDRA_Mobile_Data")
//         .doc(_auth.currentUser.email);
//
//     /// create Map to send data in key:value pair form
//     Map<String, dynamic> mobileImageData = ({
//       "Mobile_Image_Url": url,
//     });
//
//     /// send data to Firebase
//     documentReference.update(mobileImageData).whenComplete(() {
//       showToaster("Image uploaded successfully");
//       Navigator.of(context).pop();
//     });
//   }
//
//   /// Upload Status
//   // Widget buildUploadStatus(UploadTask task) {
//   //   return StreamBuilder<TaskSnapshot>(
//   //     stream: task.snapshotEvents,
//   //     builder: (context, snapshot) {
//   //       if (snapshot.hasData) {
//   //         final event = snapshot.data;
//   //         final progress = event.bytesTransferred / event.totalBytes;
//   //         final percentage = (progress * 100).toStringAsFixed(2);
//   //         return Text('$percentage %', style: simpleTextStyle());
//   //       } else {
//   //         return Text("0.0", style: simpleTextStyle());
//   //       }
//   //     },
//   //   );
//   // }
//
//   /// Remove image
//   void _clear() {
//     setState(() => _imageFile = null);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     /// Name of Selected Image
//     final selectedFileName = _imageFile != null
//         ? _imageFile.path.split("/").last
//         : "No File Selected";
//     return Scaffold(
//       // Select an image from the camera or gallery
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.yellow[700],
//         elevation: 10.0,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             IconButton(
//               iconSize: 30.0,
//               icon: Icon(Icons.photo_camera),
//               onPressed: () => _pickImage(ImageSource.camera),
//             ),
//             IconButton(
//               iconSize: 30.0,
//               icon: Icon(Icons.photo_library),
//               onPressed: () => _pickImage(ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//
//       // Preview the image and crop it
//       body: SafeArea(
//         child: ListView(
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 // ignore: deprecated_member_use
//                 FlatButton.icon(
//                   shape: materialButtonBorder(),
//                   label: Text("Crop"),
//                   color: Colors.teal[700],
//                   icon: Icon(Icons.crop),
//                   onPressed: _cropImage,
//                 ),
//                 // ignore: deprecated_member_use
//                 FlatButton.icon(
//                   shape: materialButtonBorder(),
//                   label: Text("Refresh"),
//                   color: Colors.red[700],
//                   icon: Icon(Icons.refresh),
//                   onPressed: _clear,
//                 ),
//                 // ignore: deprecated_member_use
//                 FlatButton.icon(
//                   shape: materialButtonBorder(),
//                   label: Text("Upload"),
//                   color: Colors.blue[700],
//                   icon: Icon(Icons.cloud_upload_outlined),
//                   onPressed: _uploadImage,
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.0),
//             Text(
//               selectedFileName,
//               textAlign: TextAlign.center,
//               style: simpleTextStyle(),
//             ),
//             // SizedBox(height: 10.0),
//             // _uploadTask != null
//             //     ? buildUploadStatus(_uploadTask)
//             //     : Text("0.0", style: simpleTextStyle()),
//             SizedBox(height: 20.0),
//             if (_imageFile != null) ...[
//               Image.file(_imageFile),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
