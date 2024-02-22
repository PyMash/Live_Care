import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/mainPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  Future<void> _signUp() async {
    try {
      // Validation checks for empty fields

      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
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
      setState(() {
        loading = true;
      });

      // Perform signup if all validations pass
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'Name': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'profilePicture': ''
      });
      loading = false;

      // Navigate to the next screen or perform any other actions after successful signup
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Live Care',
              style: GoogleFonts.montserrat(
                  letterSpacing: 1.0,
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Register Now',
              style: GoogleFonts.montserrat(
                  letterSpacing: 1.0,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
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
            SizedBox(height: 20.0),
            loading
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 6, 36, 8),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: ElevatedButton(
                      // onPressed: _signUp,
                      onPressed: () {

                        _signUp();
                      },

                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),
                  ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) =>  SignUpPage()));
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Already have an account?',
                  style: GoogleFonts.redHatDisplay(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
