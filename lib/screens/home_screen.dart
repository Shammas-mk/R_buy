import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_task/model/user_model.dart';
import 'package:fcm_task/screens/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  bool isSub = false;
  String? token;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      isSub = loggedInUser.isSub!;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 150,
                child: Image.asset("assets/logo.png", fit: BoxFit.contain),
              ),
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("${loggedInUser.name}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  )),
              Text("${loggedInUser.email}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 15),
              ActionChip(
                  backgroundColor: Colors.redAccent,
                  label: isSub
                      ? const Text(
                          "UnSubscribe",
                          style: TextStyle(color: Colors.white),
                        )
                      : const Text(
                          "Subscribe",
                          style: TextStyle(color: Colors.white),
                        ),
                  onPressed: () {
                    isSub = !isSub;
                    subcribe();
                    setState(() {});
                  }),
              const SizedBox(height: 15),
              ActionChip(
                  label: const Text("Send Notification"),
                  onPressed: () {
                    Get.to(() => const NotificationScreen());
                  }),
              const SizedBox(height: 15),
              ActionChip(
                  label: const Text("Logout"),
                  onPressed: () {
                    logout(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginScreen());
  }

  subcribe() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.token = token;
    userModel.name = loggedInUser.name;
    userModel.isSub = isSub;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "");
    getToken();
  }

  getToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    isSub ? token = '' : token = await firebaseMessaging.getToken();
    log(token.toString());
  }
}
