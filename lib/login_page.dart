import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/forget_password_page.dart';
import 'package:live_care/mainPage.dart';
import 'package:live_care/signup_doctor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

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
            const SizedBox(
              height: 15,
            ),
            Text(
              'Log In',
              style: GoogleFonts.montserrat(
                  letterSpacing: 1.0,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: _emailController,
              decoration: const InputDecoration(
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
              decoration: const InputDecoration(
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>  ForgetPasswordPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                    child: Text(
                      'Forget Password?',
                      style: GoogleFonts.redHatDisplay(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            loading
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 6, 36, 8),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width / 2.6,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        if (_emailController.text.trim().isEmpty ||
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
                        } else {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.message ==
                                'There is no user record corresponding to this identifier. The user may have been deleted.') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'User not found',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            letterSpacing: 1,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else if (e.message ==
                                'The password is invalid or the user does not have a password.') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Password Incorrect',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            letterSpacing: 1,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else if (e.message ==
                                'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          const Color.fromARGB(255, 6, 36, 8),
                                      content: Text(
                                        'Check your internet',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            letterSpacing: 1,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        "${e.message.toString()}",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            letterSpacing: 1,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            }

                            print(e);
                          }
                        }

                        setState(() {
                          loading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                      child: Text('Sign In',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              wordSpacing: 1,
                              letterSpacing: 1,
                              color: Colors.black)),
                    ),
                  ),
                  SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>  SignUpPage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'New to Live Care?',
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
