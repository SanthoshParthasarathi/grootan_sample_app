import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'custom_listtile.dart';

class CustomListViewCardWidgetYesterday extends StatelessWidget {
  final QuerySnapshot snapshot;

  const CustomListViewCardWidgetYesterday(this.snapshot, {Key? key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    DateTime startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    List<QueryDocumentSnapshot> yesterdayDocuments =
        snapshot.docs.where((document) {
      // Parse the string date value from Firebase
      String firebaseDateString = document['datetime'] as String;
      DateTime itemDateTime = DateTime.parse(firebaseDateString);

      return itemDateTime.isAfter(startOfYesterday) &&
          itemDateTime.isBefore(startOfToday);
    }).toList();

    return yesterdayDocuments.isNotEmpty
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.58,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: yesterdayDocuments.length,
              itemBuilder: (context, index) {
                DocumentSnapshot item = yesterdayDocuments[index];
                String ipAddress = item['ipaddress'] ?? "";
                String location = item['location'] ?? "";
                String time = item['datetime'] ?? "";
                String qrCodeString = item['qrCodeString'] ?? "";

                return CustomListItem(
                  ipAddress: ipAddress,
                  location: location,
                  time: time,
                  qrCodeString: qrCodeString,
                );
              },
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
              top:MediaQuery.of(context).size.height * 0.1,
            ),
            child: Container(
              margin: EdgeInsets.all(30),
              color: Colors.white,
              child: Center(
                child: Text("No data available for yesterday"),
              ),
            ),
          );
  }
}
