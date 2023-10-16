import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../model/last_login_model.dart';

Color purpleBackgroundColor = HexColor("#2d2c5c");
Color blackColor = HexColor("#000000");
Color blueColor = HexColor("#45a2f8");
Color greyColor = HexColor("#3c3b67");
Color buttonColor = HexColor("#3e3e3e");
Color greyBlack = HexColor("#121212");



List<LastLoginModel> lastLoginDetails = [
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Chennai",
      isQrAvailable: true,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Delhi",
      isQrAvailable: false,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Hyderabad",
      isQrAvailable: false,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Bangalore",
      isQrAvailable: true,
    ),
  ];


  List<LastLoginModel> lastLoginDetailsYesterdays = [
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Mumbai",
      isQrAvailable: true,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Kolkata",
      isQrAvailable: true,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Goa",
      isQrAvailable: false,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Calicut",
      isQrAvailable: false,
    ),
  ];


  List<LastLoginModel> lastLoginDetailsOthers = [
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Phuket",
      isQrAvailable: false,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Phi Phi",
      isQrAvailable: false,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Pattaya",
      isQrAvailable: true,
    ),
    LastLoginModel(
      time: "202-10-13 21:34:03",
      ipAddress: "123.123.123.123",
      location: "Bangkok",
      isQrAvailable: true,
    ),
  ];