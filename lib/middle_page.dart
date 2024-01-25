import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiddlePage extends StatefulWidget {
  const MiddlePage({super.key});

  @override
  State<MiddlePage> createState() => _MiddlePageState();
}

class _MiddlePageState extends State<MiddlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Coming Soon...',style: GoogleFonts.poppins(letterSpacing: 1,color: Colors.black),),),
    );
  }
}