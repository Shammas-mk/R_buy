import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcm_task/controllers/notification_controller.dart';
import 'package:fcm_task/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final titleEditingController = TextEditingController();
  final bodyEditingController = TextEditingController();
  final imageEditingController = TextEditingController();

  NotificationController notificationController =
      Get.put(NotificationController());

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  List token = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleField = TextFormField(
        autofocus: false,
        controller: titleEditingController,
        keyboardType: TextInputType.text,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Title cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Title(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          titleEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Title",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final bodyField = TextFormField(
        autofocus: false,
        controller: bodyEditingController,
        keyboardType: TextInputType.text,
        validator: (value) {
          RegExp regex = RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("Body cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid body(Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          bodyEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Body",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final imageField = TextFormField(
        autofocus: false,
        controller: bodyEditingController,
        keyboardType: TextInputType.text,
        validator: (value) {
          RegExp regex = RegExp(
              r"(https?://)?(www\.)?[a-zA-Z0-9_-]+(\.[a-zA-Z]+)+(/[a-zA-Z0-9#?&=_-]+)*");
          if (value!.isEmpty) {
            return ("Field cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Field (Min. 3 Character)");
          }
          return null;
        },
        onSaved: (value) {
          bodyEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Body",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            getAllToken();
            if (_formKey.currentState!.validate()) {
              // signUp(emailEditingController.text, passwordEditingController.text);

              notificationController.sendPushMessage(
                  loggedInUser.token.toString(),
                  bodyEditingController.text,
                  titleEditingController.text);
            }
          },
          child: const Text(
            "Send Notification",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 180,
                        child: Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.contain,
                        )),
                    const SizedBox(height: 45),
                    titleField,
                    const SizedBox(height: 20),
                    bodyField,
                    const SizedBox(height: 20),
                    Visibility(
                      visible: true,
                      child: imageField,
                    ),
                    const SizedBox(height: 20),
                    signUpButton,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getAllToken() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    if (querySnapshot.docs.isNotEmpty) {
      List<DocumentSnapshot> documentList = querySnapshot.docs;
      token = (documentList).toList();
      log('this is the data frm all token $token');
      // do something with the document list
    } else {
      // no documents found in the collection
    }
  }
}
