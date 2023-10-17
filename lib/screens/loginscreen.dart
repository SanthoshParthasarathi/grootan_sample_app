import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grootan_app/screens/pluginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants/constants.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String verificationIdRecieved = "";

  bool otpCodeVisible = false;

  String ipAddress = "Fetching...";

  String currentUserId = "";

  Future<void> getIPAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          if (mounted) {
            setState(() {
              ipAddress = addr.address;
              print("printing ip address $ipAddress");
            });
          }
        }
      }
    }
  }

  LocationData? _locationData;
  String? _cityName;
  bool _serviceEnabled = false;
  permission_handler.PermissionStatus _permissionGranted =
      permission_handler.PermissionStatus.denied;

  Future<void> checkLocationPermission() async {
    _serviceEnabled = await Location().serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await Location().requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await permission_handler.Permission.location.status;
    if (_permissionGranted.isDenied) {
      await permission_handler.Permission.location.request();
    }

    if (_permissionGranted.isGranted) {
      final location = Location();
      _locationData = await location.getLocation();

      // Use the geocoding package to get the city name from coordinates
      final placemarks = await geocoding.placemarkFromCoordinates(
        _locationData!.latitude!,
        _locationData!.longitude!,
      );

      if (placemarks.isNotEmpty) {
        _cityName = placemarks[0].locality;
      }

      if (mounted) {
        setState(() {});
      }
      print(_cityName);
      print("prints cityname");
    }
  }

  void loginWithPhone() async {
    String enteredPhoneNumber = phoneNumberController.text;
    if (enteredPhoneNumber.length == 10) {
      auth.verifyPhoneNumber(
        phoneNumber: "+91${phoneNumberController.text}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) {
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          print("verification failed +91${phoneNumberController.text}");
        },
        codeSent: (String verificationId, int? resendToken) {
          otpCodeVisible = true;
          verificationIdRecieved = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      Fluttertoast.showToast(
        msg: "Please enter a 10-digit phone number",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // addDocumentIdToSF() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('documentIdPrefs', documentReferenceId);
  // }

  // Future<void> startDelayedTask() async {
  //   _showLoadingDialog();
  //   await Future.delayed(const Duration(seconds: 3));
  //   // ignore: use_build_context_synchronously
  //   Navigator.of(context, rootNavigator: true).pop();
  //   goToPluginScreen(context);
  // }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dialog from being dismissed by tapping outside
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text("Loading please wait.."),
            ],
          ),
        );
      },
    );
  }

  Future<void> getIsUserLoggedInValueFromPluginScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isUserLoggedIn = prefs.getString('isUserLoggedIn');
      });
      // print("printing isUserLoggedIn testing value here");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var isUserLoggedIn;

  Future<void> setBoolValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        prefs.setString('isUserLoggedIn', 'true');
        isUserLoggedIn = prefs.getString('isUserLoggedIn');
      });
      // print("printing isUserLoggedIn testing value here");
    }
    print("isUserLoggedIn - YES");
  }

  var userDocumentId;

  Future<void> setDocumentIdValue(String currentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        prefs.setString('userDocumentId', currentId);
        userDocumentId = prefs.getString('isUserLoggedIn');
      });
    }
    print("userDocumentId - YES");
    print("user document id which is saved $userDocumentId");
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIdRecieved, smsCode: otpController.text);
    UserCredential userCredential = await auth.signInWithCredential(credential);
    print("You are logged in successfully");
    await getIPAddress();
    print("Prints IP above");
    await checkLocationPermission();
    print("Prints city name above");
    // await setBoolValue();
    print("isUserLoggedIn - Yes Yes");
    print("entering store user details function");
    await storeUserDetails();
    print("User details stored successfully");
    // await startDelayedTask();
    await Fluttertoast.showToast(
      msg: "You are logged in successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: blueColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDateTime;
  }

  String documentReferenceId = "";

  String? documentReferenceIdTesting;

  Future<void> getDocumentReferenceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        documentReferenceIdTesting = prefs.getString('documentReferenceId');
      });
    }
  }

  Future<void> storeUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      String currentDateTime = getCurrentDateTime();
      print("hello from storeUserDetails");
      // Generate a custom user ID, e.g., combining Firebase UID and a timestamp
      String customUserId = "$uid-${DateTime.now().millisecondsSinceEpoch}";
      // Set the documentReferenceId
      if (mounted) {
        setState(() {
          documentReferenceId = customUserId;
        });
      }
      print(
          "$documentReferenceId this is doc id and $customUserId this is custom user id");
      print("print after storing customUserId to documentReferenceId");

      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('user_details');

      // Create a map of data you want to add or update in the document
      Map<String, dynamic> userData = {
        'userId': uid,
        'ipaddress': ipAddress,
        'location': _cityName,
        'datetime': currentDateTime,
        'qrCodeString': '',
        'qrCodeImage': '',
      };
      // Use the `add` method to create a new document with a unique ID
      await collectionReference.doc(customUserId).set(userData);
      // Store the documentReferenceId in shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('documentReferenceId', documentReferenceId);
      print('Document ID: $documentReferenceId');
      await setDocumentIdValue(customUserId);
      print("testing document id $documentReferenceIdTesting");
      print(ipAddress);
      print(_cityName);
      print(currentDateTime);
      print("Inside store user details function");
      await Future.delayed(const Duration(seconds: 3), () {
        // Use the Navigator to navigate to a new page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => PluginScreen(
                    currentUserId: customUserId,
                  )),
        );
      });

      print("document ref id is received $documentReferenceId here");
      print("set state runs");
    }
  }

  Widget customTextfield(TextEditingController controller) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: purpleBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            // color: Colors.grey,
            // width: 0.0,
            ),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(10),
        ],
        controller: controller,
        style: const TextStyle(
          color: Colors.white, // Set the text color to white
        ),
        decoration: InputDecoration(
          fillColor: purpleBackgroundColor,
          border: InputBorder.none, // Hide the default border
          // hintText: 'Enter text',
          contentPadding: const EdgeInsets.all(10.0),
        ),
      ),
    );
  }

  Widget customCircleAvatar(String text) {
    return CircleAvatar(
      backgroundColor: greyColor,
      radius: 70,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

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
              child: customCircleAvatar(""),
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
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                        customTextfield(phoneNumberController),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.025,
                        ),
                        Visibility(
                          visible: otpCodeVisible,
                          child: const Text(
                            "OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: otpCodeVisible,
                          child: customTextfield(otpController),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (otpCodeVisible) {
                                  print("otp code status $otpCodeVisible");
                                  print("verify otp pressed");
                                  await setBoolValue();
                                  print(
                                      "printing isUserLogged in value inside verify button $isUserLoggedIn");
                                  verifyOTP();
                                } else {
                                  loginWithPhone();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: Text(
                                otpCodeVisible ? 'VERIFY' : 'LOGIN',
                                style: const TextStyle(
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
                      'LOGIN',
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
          ],
        ),
      ),
    );
  }
}
