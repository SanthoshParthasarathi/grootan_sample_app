// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grootan_app/screens/loginscreen.dart';
import 'package:grootan_app/screens/pluginscreen.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final User? user = _firebaseAuth.currentUser;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grootan Sample App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _userSignedOut = false;
  bool _biometricInProgress = false;
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

  var isUserLoggedIn;

  Future<void> checkIsUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // prefs.setString('isUserLoggedIn', 'false');
        isUserLoggedIn = prefs.getString('isUserLoggedIn');
        print("isUserLoggedIn value before removing $isUserLoggedIn");
      });
    }

    print("isUserLoggedIn - YES");
  }

  var userDocumentId;

  Future<void> getUserDocumentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // prefs.setString('isUserLoggedIn', 'false');
        isUserLoggedIn = prefs.getString('userDocumentId');
        print("userDocumentId value before removing $userDocumentId");
      });
    }
    print("isUserLoggedIn - YES");
  }

  @override
  void initState() {
    super.initState();
    checkIsUserLoggedIn();
    getUserDocumentId();
    checkLocationPermission();
    // _checkBiometricAndNavigate();
  }

  Future<void> checkBiometricAndNavigate(BuildContext context) async {
    if (!_userSignedOut) {
      bool isAuthenticated = false;

      try {
        isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access the app',
          stickyAuth: true,
        );
      } catch (e) {
        print(e);
      }

      if (isAuthenticated) {
        // Navigate to the plugin screen on successful authentication
        await getUserDocumentId();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PluginScreen(
                  currentUserId: userDocumentId,
                ),
          ),
        );
      } else {
        // Check if the device supports biometric authentication
        // if (await _localAuth.canCheckBiometrics) {
        //   // Display a toast message if biometric authentication is not supported
        //   Fluttertoast.showToast(
        //     msg: 'Biometric authentication is not supported on this device.',
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.CENTER,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //   );
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.delayed(Duration.zero, () => _firebaseAuth.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          User? user = snapshot.data;
          if (user != null && isUserLoggedIn == "true") {
            // User is authenticated and logged in, call checkBiometricAndNavigate
            checkBiometricAndNavigate(context); // Pass the context
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ); // or any loading indicator
          } else {
            // User is not authenticated or not logged in, display the login screen
            return const LoginScreen();
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

