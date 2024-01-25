import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    super.initState();
    _selectedSpecialization =
        _specializations.first; // Set to the first specialization by default
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final List<String> _specializations = [
    'Dermatology',
    'Ophthalmology',
    'Neurology',
    'Orthopedics',
    'Gynecology',
    'Cardiology',
  ];

  late String _selectedSpecialization;

  Future<void> _signUp() async {
    try {
      // Validation checks for empty fields

      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _registrationNumberController.text.trim().isEmpty ||
          _aboutController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill in all fields',
              style: GoogleFonts.poppins(letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }
      if (dpUrl == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please Upload a image',
              style: GoogleFonts.poppins(letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validation check for email format
      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
          .hasMatch(_emailController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid email address',
              style: GoogleFonts.poppins(letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validation check for password strength
      if (_passwordController.text.trim().length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password must be at least 6 characters',
              style: GoogleFonts.poppins(letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Perform signup if all validations pass
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('doctors').doc(userCredential.user!.uid).set({
        'Name': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'rated' : '4',
        'specialization': _selectedSpecialization,
        'registrationNumber': _registrationNumberController.text.trim(),
        'about': _aboutController.text.trim(),
        'profilePicture':
            dpUrl, // Assuming you want to store the profile picture URL
      });

      // Navigate to the next screen or perform any other actions after successful signup
    } catch (e) {
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$e',
            style: GoogleFonts.poppins(letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Handle signup errors here
    }
  }

  File? _imageFile;
  bool _isLoadingImage = false;
  String dpUrl = '';

  Future<void> _uploadImage() async {
    await _pickImage();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _imageFile != null) {
      try {
        // Show circular progress indicator
        showDialog(
          context: context,
          barrierDismissible: false, // To prevent tapping outside to dismiss
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('Profile Picture')
            .child(_nameController.text)
            .child('dp.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final storageSnapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();

        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(user.uid)
        //     .update({'profilepicture': downloadUrl});
        dpUrl = downloadUrl;

        // Hide circular progress indicator
        Navigator.pop(context);

        // setState(() {
        //   _fetchUserData();
        // });

        // Navigate to ProfilePage
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainPage()),
        // );
      } catch (error) {
        print('Error uploading image: $error');
        // Hide circular progress indicator
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image')),
        );
      }
    }
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Live Care',
              style: GoogleFonts.montserrat(
                  letterSpacing: 1.0,
                  fontSize: MediaQuery.of(context).size.width * 0.1,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Register Now',
              style: GoogleFonts.montserrat(
                  letterSpacing: 1.0,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  style: ElevatedButton.styleFrom(
                      shape: LinearBorder(),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade200),
                  child: Text(
                    "Upload Your Picture",
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
              ),
            ),
            DropdownButtonFormField(
              value: _selectedSpecialization,
              alignment: Alignment.center,
              onChanged: (value) {
                setState(() {
                  _selectedSpecialization = value!;
                });
              },
              items: _specializations.map((specialization) {
                return DropdownMenuItem(
                  value: specialization,
                  child: Text(
                    specialization,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Specialization',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _aboutController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'About Yourself (at least 200 words)',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _registrationNumberController,
              decoration: InputDecoration(
                labelText: 'Registration Number (NCRM No)',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                // onPressed: _signUp,
                onPressed: () {
                  print(dpUrl);
                  _signUp();
                },

                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
