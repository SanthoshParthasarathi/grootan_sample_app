import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'custom_listtile.dart';

class CustomListViewCardWidgetOthers extends StatelessWidget {
  final QuerySnapshot snapshot;

  const CustomListViewCardWidgetOthers(this.snapshot, {Key? key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);

    List<QueryDocumentSnapshot> otherDocuments =
        snapshot.docs.where((document) {
      // Parse the string date value from Firebase
      String firebaseDateString = document['datetime'] as String;
      DateTime itemDateTime = DateTime.parse(firebaseDateString);

      return itemDateTime.isBefore(startOfToday);
    }).toList();

    return otherDocuments.isNotEmpty
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.58,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: otherDocuments.length,
              itemBuilder: (context, index) {
                DocumentSnapshot item = otherDocuments[index];
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
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Container(
              margin: const EdgeInsets.all(30),
              color: Colors.white,
              child: const Center(
                child: Text("No data available for Other Dates"),
              ),
            ),
          );
  }
}
