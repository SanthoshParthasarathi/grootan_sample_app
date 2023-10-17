import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grootan_app/widgets/custom_listtile.dart';

class CustomListViewCardWidget extends StatelessWidget {
  final QuerySnapshot snapshot;

  const CustomListViewCardWidget(this.snapshot, {Key? key});

  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime today = DateTime.now();
    // Create a DateTime object for the start of today (midnight)
    DateTime startOfToday = DateTime(today.year, today.month, today.day);

    // Filter the documents to include only those with a datetime field equal to or greater than startOfToday
    List<QueryDocumentSnapshot> todayDocuments = snapshot.docs.where((document) {
      DateTime itemDateTime = DateTime.parse(document['datetime'] as String);
      return itemDateTime.isAtSameMomentAs(startOfToday) || itemDateTime.isAfter(startOfToday);
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.58,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: todayDocuments.length,
        itemBuilder: (context, index) {
          DocumentSnapshot item = todayDocuments[index];
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
    );
  }
}

