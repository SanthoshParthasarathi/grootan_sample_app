import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grootan_app/screens/last_loginscreen.dart';
import 'package:grootan_app/screens/loginscreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants/constants.dart';

class PluginScreen extends StatefulWidget {
  final String? currentUserId;

  const PluginScreen({
    super.key,
    this.currentUserId,
    // required this.currentUserId,
  });

  @override
  State<PluginScreen> createState() => _PluginScreenState();
}

class _PluginScreenState extends State<PluginScreen> {
  String randomString = '';

  String documentIdFromPrefs = "";

  void generateRandomString(int length) {
    const alphanumericChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final codeUnits = List.generate(
      length,
      (index) => alphanumericChars.codeUnitAt(
        random.nextInt(alphanumericChars.length),
      ),
    );
    setState(() {
      randomString = String.fromCharCodes(codeUnits);
    });
  }

  // bool isUserLoggedIn = false;
  var isUserLoggedIn;

  Future<void> setUserLoggedInValueBackToFalse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // prefs.setString('isUserLoggedIn', 'false');
        isUserLoggedIn = prefs.getString('isUserLoggedIn');
        print("isUserLoggedIn value before removing $isUserLoggedIn");
        prefs.remove('isUserLoggedIn');
        print("printing isUserLoggedIn testing value here $isUserLoggedIn");
        // isUserLoggedIn = prefs.getString('isUserLoggedIn');
      });
      // print("printing isUserLoggedIn testing value here");
    }

    print("isUserLoggedIn - YES");
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await setUserLoggedInValueBackToFalse();
      print(
          "printing $isUserLoggedIn user logged in value inside signout page");
      print("removed isUserLoggedIn because you have logged out");
      await FirebaseAuth.instance.signOut();
      await Fluttertoast.showToast(
          msg: "Logged out Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: blueColor,
          textColor: Colors.white,
          fontSize: 16.0);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      ); // Replace with your login screen route
    } catch (e) {
      // Handle sign-out errors if necessary
      print("Error signing out: $e");
    }
  }

  Widget customCircleAvatar(String text) {
    return InkWell(
      onTap: () {
        signOut(context);
      },
      child: CircleAvatar(
        backgroundColor: greyColor,
        radius: 70,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// convert qr string to a image
  Future<Uint8List> generateQRCodeImage(String qrCodeString) async {
    final qrPainter = QrPainter(data: qrCodeString, version: QrVersions.auto);
    final qrCodeImage =
        await qrPainter.toImageData(200, format: ImageByteFormat.png);
    return Uint8List.fromList(qrCodeImage!.buffer.asUint8List());
  }

  String documentId = "";

//// save qrstring and qr image to firebase
  Future<void> saveQrString(String qrCodeString) async {
    // Generate the QR code image and encode it in base64
    final qrCodeImage = await generateQRCodeImage(qrCodeString);
    final qrCodeImageBase64 = base64Encode(qrCodeImage);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('user_details');
      DocumentReference documentRef = collectionReference.doc();

      print("prints document id");
      print("prints doc id inside save button ${widget.currentUserId}");

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('user_details')
          .doc(widget.currentUserId);

      // Use the 'update' method to add the 'qrCodeString' and 'qrCodeImage' fields
      documentReference.update({
        'qrCodeString': qrCodeString,
        'qrCodeImage': qrCodeImageBase64,
      });

      print('Added qrCodeString: $qrCodeString');
    }

    // Display a toast notification
    await Fluttertoast.showToast(
      msg: "QR String Saved Successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: blueColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  late Stream<QuerySnapshot> itemsStream;
  String lastDatetime = "";

  String? documentReferenceId;
  String stringValue = "";

  Future<void> getDocumentReferenceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      documentReferenceId = prefs.getString('documentReferenceId');
    });
  }

  removeValues(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Remove String
    prefs.remove("documentReferenceId");
  }

  void removeBoolValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isUserLoggedIn');
  }

  // setDocumentReferenceValue(String documentId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     prefs.setString('documentReferenceId', documentId);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5));

    getDocumentReferenceId();
    print("prints document id from sf $documentReferenceId here");

    print(widget.currentUserId);
    print("prints document id ${widget.currentUserId} here");
    generateRandomString(6);
  }

  //  itemsStream = FirebaseFirestore.instance
  //       .collection('user_details')
  //       .orderBy('datetime', descending: true)
  //       .snapshots();

  //   itemsStream.listen((itemsList) {
  //     if (itemsList.docs.isNotEmpty) {
  //       final lastDocument = itemsList.docs.first;
  //       final datetime = lastDocument['datetime'] as String;
  //       if (mounted) {
  //         setState(() {
  //           lastDatetime = datetime;
  //         });
  //       }
  //     }
  //   });
  //   print("prints lastdatetime $lastDatetime");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      // ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: customCircleAvatar("Logout"),
            ),
            Positioned(
              top: 150,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26.0),
                  topRight: Radius.circular(26.0),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: blackColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.14,
                        ),
                        Card(
                          elevation: 5,
                          child: Center(
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.335,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  stops: const [0.5, 0.5],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.grey.shade900,
                                    purpleBackgroundColor, // top Right part
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LastLoginScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.grey), // Border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                              ),
                              child: const Text(
                                'Last Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.025,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: ElevatedButton(
                              onPressed: () {
                                saveQrString(randomString);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: const Text(
                                'SAVE',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 125,
              left: 60,
              right: 60,
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.35,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(
                        10.0), // Adjust the radius as needed
                  ),
                  child: const Center(
                    child: Text(
                      'PLUGIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 60,
              right: 60,
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.white,
                        child: QrImageView(
                          data: randomString,
                          version: QrVersions.auto,
                          size: 170.0,
                        ),
                        // Image.asset(
                        //   "assets/images/qr_image.png",
                        //   height: 170,
                        //   width: 170,
                        // ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  const Text(
                    'Generated Number',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.045,
                  ),
                  Text(
                    randomString,
                    style: const TextStyle(
                      letterSpacing: 3,
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
