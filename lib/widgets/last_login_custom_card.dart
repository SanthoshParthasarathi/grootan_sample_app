import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grootan_app/widgets/custom_listtile.dart';

class CustomListViewCardWidget extends StatelessWidget {
  final QuerySnapshot snapshot;

  const CustomListViewCardWidget(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.58,
      child: ListView.builder(
        shrinkWrap: true,
        // reverse: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot item = snapshot.docs[index];
          // Use the null-aware operator (??) to provide a default value if the field is not present
          String ipAddress = item['ipaddress'] ?? "";
          String location = item['location'] ?? "";
          String time = item['datetime'] ?? "";
          // bool isQrAvailable = item['isQrAvailable'] ?? false;
          String qrCodeString = item['qrCodeString'] ?? "";
          return CustomListItem(
            ipAddress: ipAddress,
            location: location,
            time: time,
            // isQrAvailable: isQrAvailable,
            qrCodeString: qrCodeString,
          );
        },
      ),
    );
  }
}
