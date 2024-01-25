import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>(); //key for form
  String name = "";
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade400,
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        'Enter your email address to reset your password',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextFormField(
                        controller: _emailController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(10.0),
                            filled: true,
                            hintText: 'Email ID',
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),borderSide: BorderSide(color: Colors.white))),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                            return "Invalid Format";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    loading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width / 2.2,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });

                                if (formKey.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                            email:
                                                _emailController.text.trim());
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            content: Text(
                                              'Password reset link send! check your email',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        });
                                    Timer(const Duration(seconds: 3), () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyApp()));
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                Color.fromARGB(255, 6, 36, 8),
                                            content: Text(
                                              e.message.toString(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )));
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
                              child: Text('Reset Password',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      letterSpacing: 1.5,
                                      color: Colors.black)),
                            ),
                          ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromARGB(255, 6, 36, 8),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
