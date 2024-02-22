import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade300,
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: Colors.cyan,
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     'About Us',
        //     style: GoogleFonts.poppins(
        //         color: Colors.white, fontSize: 18, letterSpacing: 1.5),
        //   ),
        //   iconTheme: IconThemeData(
        //     color: Colors.white, // Replace yourColor with the desired color
        //   ),
        // ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.10,
                ),
                Text(
                  'Live Care',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.redHatDisplay(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.07),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Introducing Live Care, your ultimate solution for hassle-free doctor appointment booking with live chat features. Whether you're scheduling routine check-ups or seeking immediate medical advice, Live Care offers a seamless platform to connect with healthcare professionals. With Live Care, you can effortlessly book appointments, engage in real-time conversations with doctors, and receive expert guidance from the comfort of your home.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                      letterSpacing: 1,
                      // fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.032),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  'About us',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.redHatDisplay(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.055),
                ),
                const SizedBox(
                  height: 8,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "Meet the minds behind Live Care! As the passionate developers of this revolutionary app, we are dedicated Computer Science students from Galgotias University pursuing our MCA degree. Led by ",
                    style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Mashud Ahmed Talukdar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ", along with ",
                      ),
                      TextSpan(
                        text: "Anurag Kumar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: " and ",
                      ),
                      TextSpan(
                        text: "Pankaj Kushwaha",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text:
                            ", we combine technical expertise with a deep understanding of user experience to ensure Live Care caters to the diverse needs of its users.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'You can reach us at',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.040),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'https://github.com/PyMash',
                  style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      // height: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.032),
                ),
                // SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text(
                //       'mashudworkmail@gmail.com',
                //       style: GoogleFonts.poppins(
                //           letterSpacing: 1.2,
                //           height: 1,
                //           fontWeight: FontWeight.w500,
                //           fontSize: MediaQuery.of(context).size.width * 0.034),
                //     ),
                //     // SizedBox(width: 10,),
                //     // GestureDetector(
                //     //   onTap: (){
                //     //      Clipboard.setData(const ClipboardData(
                //     //           text: 'mashudworkmail@gmail.com'));
                //     //       ScaffoldMessenger.of(context)
                //     //           .showSnackBar(const SnackBar(
                //     //         content: Text(
                //     //           'Copied email address',
                //     //           textAlign: TextAlign.center,
                //     //         ),
                //     //         duration: Duration(seconds: 1),
                //     //       ));
                //     //   },
                //     //   child: Icon(
                //     //         Icons.copy,
                //     //         size: MediaQuery.of(context).size.width * 0.05,
                //     //       ),
                //     // )
                //   ],
                // ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.08,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_sharp))
              ],
            ),
          ),
        ));
  }
}
