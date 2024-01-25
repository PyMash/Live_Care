import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserProfile();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();

  //fetch user details
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String profilePicture = '';
  late String Name = '';
  late String Email = '';

  Future<void> _fetchUserProfile() async {
    final User? user = _auth.currentUser;

      // Fetch the user data from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user!.uid).get();

      if (userDoc.exists) {
        final fetchedUrl = userDoc['profilePicture'] ?? '';
        final fetchedName = userDoc['Name'] ?? '';
        final fetchedEmail = userDoc['Email'] ?? '';
        print('Fetched Profile Picture URL: $fetchedUrl'); // Debug print
        print('Fetched Name: $fetchedName'); // Debug print
        print('Fetched Email: $fetchedEmail'); 

        setState(() {
          profilePicture = fetchedUrl ?? ''; // Ensure it's not null
          Name = fetchedName ?? '';
          Email = fetchedEmail ?? '';
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade300,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.redHatDisplay(
              letterSpacing: 1.2, fontWeight: FontWeight.w500,color: Colors.black),
        ),
        backgroundColor: Colors.cyan.shade300,
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
                  radius: 42,
                  backgroundImage: (profilePicture.isNotEmpty)
                      ? NetworkImage(profilePicture)
                          as ImageProvider<Object>?
                      : null, // Don't specify any image here
                  child: (profilePicture.isEmpty)
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
                SizedBox(
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
              color: Colors.white,
              height: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOptionTile('Edit Profile', Icons.settings, () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => EditProfilePage(),
                  //   ),
                  // );
                }),
                _buildOptionTile('Appoinments', Icons.tune, () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => MyListViewPage(),
                  //   ),
                  // );
                }),
                _buildOptionTile('Help & Support', Icons.phone, () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const HelpPage(),
                  //   ),
                  // );
                }),
                _buildOptionTile('About Us', Icons.help, () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const AboutPage(),
                  //   ),
                  // );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              color: Colors.white,
              height: 2,
            ),
          ),
          SizedBox(
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
                              builder: (context) => MyApp()), // Your new screen
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        ));
              } catch (error) {
                print(error.toString());
              }
            }, // Handle log out action
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Log out',
                  style: GoogleFonts.poppins(
                      letterSpacing: 1, color: Colors.black),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: 18,
                )
              ],
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerRight,
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon,color: Colors.black,),
      title: Text(title,style: TextStyle(color: Colors.black),),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}
