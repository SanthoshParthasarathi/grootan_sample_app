import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomListItem extends StatelessWidget {
  final String time;
  final String ipAddress;
  final String location;
  final bool? isQrAvailable;
  final String qrCodeString;

  const CustomListItem({
    super.key,
    required this.time,
    required this.ipAddress,
    required this.location,
    this.isQrAvailable,
    required this.qrCodeString,
  });

  String formatApiDateTime(String apiDateTime) {
    // Parse the API date and time string into a DateTime object
    DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(apiDateTime);

    // Format the DateTime object into the desired format
    String formattedDateTime = DateFormat('h:mm a').format(dateTime);

    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = formatApiDateTime(time);
    print(qrCodeString);
    print("prints qrcodestring");
    return Stack(
      children: [
        Container(
          height: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white24,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDateTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "IP : $ipAddress",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              location.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: qrCodeString != "" && qrCodeString != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.white,
                    height: 100,
                    width: 100,
                    child: QrImageView(
                      data: qrCodeString,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    // Image.asset(
                    //   "assets/images/qr_image.png",
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                )
              : Container(),
        ),
      ],
    );
  }
}
