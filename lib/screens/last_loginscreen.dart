import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grootan_app/screens/loginscreen.dart';
import 'package:grootan_app/services/services.dart';
import 'package:grootan_app/widgets/custom_lastlogin_card_others.dart';
import 'package:grootan_app/widgets/custom_lastlogin_card_today.dart';
import 'package:grootan_app/widgets/custom_lastlogin_card_yesterday.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants/constants.dart';
import '../widgets/custom_listtile.dart';

class LastLoginScreen extends StatefulWidget {
  const LastLoginScreen({super.key});

  @override
  State<LastLoginScreen> createState() => _LastLoginScreenState();
}

class _LastLoginScreenState extends State<LastLoginScreen>
    with SingleTickerProviderStateMixin {
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

  late TabController _tabController;

  String documentIdPrefs = "";
  Future<void> removeDocumentId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('documentId');
    setState(() {
      documentIdPrefs = '';
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      removeDocumentId();
      await FirebaseAuth.instance.signOut();
      // Set the userSignedOut value to true in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userSignedOut', true);
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpleBackgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 40,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
            ),
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
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: blackColor, // Background color of tabs
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            indicatorWeight: 5,
                            indicatorColor: Colors.white,
                            unselectedLabelStyle: const TextStyle(fontSize: 14),
                            unselectedLabelColor: Colors.white,
                            labelStyle: const TextStyle(fontSize: 18),
                            tabs: const [
                              Tab(text: 'Today'),
                              Tab(text: 'Yesterday'),
                              Tab(text: 'Others'),
                            ],
                            onTap: (index) {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),
                        ),
                        IndexedStack(
                          index: selectedIndex,
                          children: [
                            /// today
                            StreamBuilder<QuerySnapshot>(
                              stream: Services().getItems(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                return CustomListViewCardWidget(snapshot.data!);
                              },
                            ),
                            /// yesterday
                            StreamBuilder<QuerySnapshot>(
                              stream: Services().getItems(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                return CustomListViewCardWidgetYesterday(snapshot.data!);
                              },
                            ),
                            /// other dates
                            StreamBuilder<QuerySnapshot>(
                              stream: Services().getItems(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(color: Colors.amber,));
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                return CustomListViewCardWidgetOthers(snapshot.data!);
                              },
                            ),
                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   itemCount: lastLoginDetailsYesterdays.length,
                            //   itemBuilder: (context, index) {
                            //     return CustomListItem(
                            //       time: lastLoginDetailsYesterdays[index]
                            //           .time
                            //           .toString(),
                            //       ipAddress: lastLoginDetailsYesterdays[index]
                            //           .ipAddress
                            //           .toString(),
                            //       location: lastLoginDetailsYesterdays[index]
                            //           .location
                            //           .toString(),
                            //       isQrAvailable:
                            //           lastLoginDetailsYesterdays[index]
                            //               .isQrAvailable,
                            //     );
                            //   },
                            // ),
                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   itemCount: lastLoginDetailsOthers.length,
                            //   itemBuilder: (context, index) {
                            //     return CustomListItem(
                            //       time: lastLoginDetailsOthers[index]
                            //           .time
                            //           .toString(),
                            //       ipAddress: lastLoginDetailsOthers[index]
                            //           .ipAddress
                            //           .toString(),
                            //       location: lastLoginDetailsOthers[index]
                            //           .location
                            //           .toString(),
                            //       isQrAvailable: lastLoginDetailsOthers[index]
                            //           .isQrAvailable,
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.78,
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: ElevatedButton(
                              onPressed: () {
                                  Fluttertoast.showToast(
                                    msg: 'Already saved please logout to save another instance',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: blueColor,
                                    textColor: Colors.white,
                                  );
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
                      'LAST LOGIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
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
