import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:live_care/splashScreen.dart';
import 'home_page.dart';

class DoctorDetails extends StatefulWidget {
  final String documentId;

  const DoctorDetails({Key? key, required this.documentId}) : super(key: key);

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  late Map<String, dynamic> doctorData = {}; // Initialize with an empty map
  int selectedIndex = -1;
  int selectedIndexForDate = -1;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchData() async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.documentId)
          .get();

      if (doctorSnapshot.exists) {
        setState(() {
          doctorData = doctorSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctorData == null) {
      return CircularProgressIndicator(); // You can replace this with a loading indicator or any other widget
    }

    String profilePictureUrl = doctorData['profilePicture'] ?? '';
    String doctorName = doctorData['Name'] ?? '';
    String occupation = doctorData['specialization'] ?? '';
    int rating = int.tryParse(doctorData['rated'] ?? '') ?? 0;
    String about = doctorData['about'] ?? '';
    return Scaffold(
      backgroundColor: Colors.cyan.shade300,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 100, // Set the width to desired size
                        height: 100, // Set the height to desired size
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the border radius if needed
                          image: (profilePictureUrl.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(profilePictureUrl),
                                  fit: BoxFit.cover,
                                )
                              : null, // Don't specify any image here
                        ),
                        child: (profilePictureUrl.isEmpty)
                            ? Center(
                                child: Text(
                                  generateInitials(doctorName),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            : null, // Show initials only if there's no image
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. " + doctorName,
                          style: GoogleFonts.redHatDisplay(
                            letterSpacing: 1,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                        Text(
                          occupation,
                          style: GoogleFonts.redHatDisplay(
                            letterSpacing: 1,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            rating,
                            (index) => Icon(
                              Icons.star,
                              color: Colors.amber, // Golden color
                              size: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '₹ 450.00 (Per Consultation)',
                          style: GoogleFonts.roboto(
                            letterSpacing: 0.1,
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'About doctor',
                        style: GoogleFonts.poppins(
                          letterSpacing: 0.5,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        about,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Available Time',
                        style: GoogleFonts.poppins(
                          letterSpacing: 0.5,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: List.generate(
                          8,
                          (index) => _buildSpecialtyItem(
                            index,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Available Date',
                      style: GoogleFonts.poppins(
                        letterSpacing: 0.5,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7, // You can adjust the number of days shown
                        itemBuilder: (context, index) {
                          DateTime currentDate =
                              DateTime.now().add(Duration(days: index));
                          bool isSelected = index == selectedIndexForDate;

                          return _buildDateItem(currentDate, isSelected, index);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedIndex != -1 &&
                              selectedIndexForDate != -1) {
                            final selectedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedIndex +
                                  9, // Adding 9 hours to match the selected time
                            );
                            final formattedDateTime =
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(selectedDateTime);
                            print('Selected Time: $formattedDateTime');

                            //                     await _firestore.collection('users').doc(userCredential.user!.uid).set({
                            // 'Name': _nameController.text.trim(),
                            // 'Email': _emailController.text.trim(),
                            // 'profilePicture': ''
                            // });
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SplashScreen()));
                          } else {
                            print('Please select both time and date.');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Please select both time and date to book the appointment',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    letterSpacing: 1, color: Colors.black),
                              ),
                              duration: Duration(seconds: 1),
                            ));
                          }
                        },
                        child: Text(
                          "Book Appointment",
                          style: GoogleFonts.poppins(
                              letterSpacing: 1, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildSpecialtyItem(int index) {
    final hour = index + 9; // Start from 9 AM
    final time = hour > 12 ? '${hour - 12}:00 PM' : '$hour:00 AM';

    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isSelected ? -1 : index; // Toggle selection
          print(time);
        });
      },
      child: Card(
        color: isSelected ? Colors.green : Colors.cyan.shade300,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                letterSpacing: 1,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected, int index) {
    String dayName = DateFormat('E').format(date);
    String dayNumber = DateFormat('d').format(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndexForDate = index; // Update selected index
          print(date);
        });
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.cyan,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
