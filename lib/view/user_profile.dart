import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_e_commerse_app_with_api/controller/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/user_profile_provider.dart';
import '../user_details/get_user_data.dart';
import '../user_details/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DocumentSnapshot _userProfile;

  @override
  void initState() {
    super.initState();

    // Fetch the user profile document from Firestore
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          setState(() {
            _userProfile = documentSnapshot;

            Provider.of<Userdetailsprovider>(context, listen: false)
                .usernameController
                .text = _userProfile['fullName'];
            Provider.of<Userdetailsprovider>(context, listen: false)
                .phoneNumberController
                .text = _userProfile['phone_number'];
            Provider.of<Userdetailsprovider>(context, listen: false)
                .addressController
                .text = _userProfile['address'];
            Provider.of<Userdetailsprovider>(context, listen: false)
                .ageController
                .text = _userProfile['age'].toString();
          });
        }
      });
    } catch (e) {
      print('Error fetching user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching user profile: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final getuser = Provider.of<UserDataProvider>(context);
    final userDetails = Provider.of<Userdetailsprovider>(context);
    final googleUser = Provider.of<GoogleSignInProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('User Profile',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 78, 78, 78),
                Color.fromARGB(255, 34, 32, 27),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        height: height,
        decoration: const BoxDecoration(
          // image: DecorationImage(
          //     image: NetworkImage(
          //         'https://mebincdn.themebin.com/1664962508289.png'),
          //     fit: BoxFit.cover),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 34, 32, 27),
              Color.fromARGB(255, 34, 32, 27),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height / 25,
                ),
                Center(
                  child: SizedBox(
                    height: height * 0.28,
                    child: Stack(
                      children: [
                        Consumer<UserDataProvider>(
                          builder: (context, userDataProvider, child) {
                            final authUser = FirebaseAuth.instance.currentUser;
                            if (authUser != null) {
                              if (authUser.providerData.any((provider) =>
                                  provider.providerId == 'google.com')) {
                                return StreamBuilder<Map<String, dynamic>>(
                                  stream:
                                      userDataProvider.getUserDetailsgoogle(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final data = snapshot.data!;
                                      final photoUrl =
                                          data['photoUrl'] as String;
                                      return CircleAvatar(
                                        radius: 120,
                                        backgroundImage: NetworkImage(photoUrl),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        radius: 120,
                                        backgroundImage: NetworkImage(
                                            'https://static.vecteezy.com/system/resources/previews/005/337/799/original/icon-image-not-found-free-vector.jpg'),
                                      );
                                    }
                                  },
                                );
                              } else if (authUser.providerData.any((provider) =>
                                  provider.providerId == 'password')) {
                                // User signed in with email/password
                                return StreamBuilder<Map<String, dynamic>>(
                                  stream: userDataProvider.getUserData(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final data = snapshot.data!;
                                      final photoUrl =
                                          data['photoUrl'] as String;

                                      return CircleAvatar(
                                          radius: 120,
                                          backgroundImage:
                                              NetworkImage(photoUrl));
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                              }
                            }
                            // User not signed in
                            return const SizedBox.shrink();
                          },
                        ),
                        // StreamBuilder<DocumentSnapshot>(
                        //   stream: FirebaseFirestore.instance
                        //       .collection('users')
                        //       .doc(widget.userId)
                        //       .snapshots(),
                        //   builder: (context, snapshot) {
                        //     if (snapshot.hasData) {
                        //       final data =
                        //           snapshot.data!.data() as Map<String, dynamic>;
                        //       final photoUrl = data['photoUrl'] as String;
                        //       return CircleAvatar(
                        //         radius: 120,
                        //         backgroundImage: NetworkImage(photoUrl),
                        //       );
                        //     } else {
                        //       return const Center(
                        //         child: CircularProgressIndicator(),
                        //       );
                        //     }
                        //   },
                        // ),

                        Positioned(
                          bottom: 25.0,
                          right: 0.0,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white70,
                              size: 40,
                            ),
                            onPressed: () {
                              userDetails.dpimageUser(widget.userId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 10,
                ),
                SizedBox(
                  height: height * 0.08,
                  child: TextFormField(
                    controller: Provider.of<Userdetailsprovider>(context)
                        .usernameController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.08,
                  child: TextFormField(
                    controller: Provider.of<Userdetailsprovider>(context)
                        .phoneNumberController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.08,
                  child: TextFormField(
                    controller: Provider.of<Userdetailsprovider>(context)
                        .addressController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.08,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller:
                        Provider.of<Userdetailsprovider>(context).ageController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Age',
                      labelStyle: TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.amber,
                          width: 2.0,
                        ),
                        gapPadding: 4,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      suffixStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: MediaQuery.of(context).size.width * .93,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 189, 189, 189),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      try {
                        // Update the user profile in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .update({
                          'fullName': Provider.of<Userdetailsprovider>(context,
                                  listen: false)
                              .usernameController
                              .text,
                          'phone_number': Provider.of<Userdetailsprovider>(
                                  context,
                                  listen: false)
                              .phoneNumberController
                              .text,
                          'address': Provider.of<Userdetailsprovider>(context,
                                  listen: false)
                              .addressController
                              .text,
                          'age': int.parse(Provider.of<Userdetailsprovider>(
                                  context,
                                  listen: false)
                              .ageController
                              .text),
                        });
                        // Display a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('User profile updated successfully')),
                        );
                      } catch (e) {
                        print('Error updating user profile: $e');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error updating user profile: $e'),
                        ));
                      }
                    },
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Color(0xff161b27),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
