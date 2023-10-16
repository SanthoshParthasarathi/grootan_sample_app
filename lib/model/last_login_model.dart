class LastLoginModel {
  String? time;
  String? ipAddress;
  String? location;
  bool isQrAvailable;

  LastLoginModel({
    this.time,
    this.ipAddress,
    this.location,
    required this.isQrAvailable,
  });
}
