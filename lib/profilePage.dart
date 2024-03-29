import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/booked_doctor.dart';
import 'package:live_care/help_page.dart';
import 'package:live_care/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';
import 'aboutus_page.dart';
import 'edit_profile.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();

  //fetch user details
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String profilePicture = '';
  // ignore: non_constant_identifier_names
  late String Name = '';
  // ignore: non_constant_identifier_names
  late String Email = '';
  late String _image = '';
  Future _fetchUserData() async {
    var image;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          image = userData['profilepicture'].toString();
          if (image == 'null') {
            image = '';
          }

          setState(() {
            Name = userData['Name'];
            Email = userData['Email'].toString();
            _image = image;
          });
        }
        print(_image);
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.redHatDisplay(
              letterSpacing: 1.2, fontWeight: FontWeight.w500,color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 45,
                      backgroundImage: (_image.isNotEmpty)
                          ? NetworkImage(_image) as ImageProvider<Object>?
                          : null, // Don't specify any image here
                      child: (_image.isEmpty)
                          ? Text(
                              generateInitials(Name),
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 1),
                            )
                          : null, // Show initials only if there's no image
                    ),
                const SizedBox(height: 13),
                Text(
                  Name,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  Email,
                  softWrap: true,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.7),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              color: Colors.cyan.shade200,
              height: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOptionTile('Edit Profile', Icons.settings, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(),
                    ),
                  );
                }),
                _buildOptionTile('Appoinments', Icons.tune, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FetchDetails(),
                    ),
                  );
                }),
                _buildOptionTile('Help & Support', Icons.phone, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpPage(),
                    ),
                  );
                  
                }),
                _buildOptionTile('About Us', Icons.help, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              color: Colors.cyan.shade200,
              height: 2,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () async {
              try {
                // await googleSignIn.signOut(); // Sign out from Google
                await _auth.signOut(); // Sign out from Firebase
      
                FirebaseAuth.instance
                    .signOut()
                    .then((value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()), // Your new screen
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        ));
              } catch (error) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.cyan.shade300,
                      content: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(letterSpacing: 1, color: Colors.black),
                      )));
              }
            },
            style: TextButton.styleFrom(
              alignment: Alignment.centerRight,
            ), // Handle log out action
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Log out',
                  style: GoogleFonts.poppins(
                      letterSpacing: 1, color: Colors.black),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: 18,
                )
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon,color: Colors.black,),
      title: Text(title,style: const TextStyle(color: Colors.black),),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}
