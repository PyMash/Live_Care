import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:live_care/chat_screen.dart';

class FetchDetails extends StatefulWidget {
  const FetchDetails({Key? key}) : super(key: key);

  @override
  State<FetchDetails> createState() => _FetchDetailsState();
}

class AppointmentDetails {
  final String documentId;
  final String doctorId;
  final String currentStatus;
  final DateTime dateTime;
  DoctorDetails? doctorDetails;

  AppointmentDetails(this.documentId, this.doctorId, this.currentStatus,
      this.dateTime, this.doctorDetails);
}

class DoctorDetails {
  final String name;
  final String profilePicture;
  final String specialization;

  DoctorDetails(this.name, this.profilePicture, this.specialization);
}

class _FetchDetailsState extends State<FetchDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AppointmentDetails> appointmentsWithDetails = [];

  @override
  void initState() {
    super.initState();
    fetchAppointmentsWithDoctorDetails();
  }

  Future<void> fetchAppointmentsWithDoctorDetails() async {
    try {
      final User? user = _auth.currentUser;
      List<AppointmentDetails> appointmentDetailsList =
          await fetchAppointmentsWithDetails(user!.uid);

      setState(() {
        appointmentsWithDetails = appointmentDetailsList;
      });
    } catch (e) {
      // Handle errors here (print or throw)
      print('Error fetching Appointments with DoctorDetails: $e');
    }
  }

  Future<List<AppointmentDetails>> fetchAppointmentsWithDetails(
      String userUid) async {
    List<AppointmentDetails> appointmentDetailsList = [];

    try {
      // Reference to the Firestore collection
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');
      CollectionReference bookedAppointmentCollection =
          userCollection.doc(userUid).collection('BookedAppointment');
      CollectionReference doctorsCollection =
          FirebaseFirestore.instance.collection('doctors');

      // Fetch documents from the BookedAppointment collection
      QuerySnapshot querySnapshot = await bookedAppointmentCollection.get();

      // Iterate through the documents and extract details
      for (QueryDocumentSnapshot<Object?> docSnapshot in querySnapshot.docs) {
        // Ensure the document exists
        if (docSnapshot.exists) {
          // Access the document ID, DoctorId, CurrentStatus, and DateTime
          String documentId = docSnapshot.id;
          Map<String, dynamic>? data =
              docSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            String doctorId = data['DoctorId'] as String? ?? '';
            String currentStatus = data['CurrentStatus'] as String? ?? '';
            String dateString = data['DateTime'] as String? ?? '';

            DateTime dateTime = dateString.isNotEmpty
                ? DateFormat('yyyy-MM-dd HH:mm').parse(dateString)
                : DateTime(0);

            // Fetch doctor details
            DoctorDetails? doctorDetails = await fetchDoctorDetails(doctorId);

            // Create an AppointmentDetails object and add it to the list
            AppointmentDetails appointmentDetails = AppointmentDetails(
                documentId, doctorId, currentStatus, dateTime, doctorDetails);
            appointmentDetailsList.add(appointmentDetails);
          }
        }
      }

      // Return the list of AppointmentDetails
      return appointmentDetailsList;
    } catch (e) {
      // Handle errors here (print or throw)
      print('Error fetching Appointments with DoctorDetails: $e');
      return [];
    }
  }

  Future<DoctorDetails?> fetchDoctorDetails(String doctorId) async {
    try {
      // Reference to the Firestore collection
      CollectionReference doctorsCollection =
          FirebaseFirestore.instance.collection('doctors');

      // Reference to the specific doctor's document
      DocumentSnapshot doctorSnapshot =
          await doctorsCollection.doc(doctorId).get();

      // Check if the document exists
      if (doctorSnapshot.exists) {
        // Access the doctor details
        Map<String, dynamic>? data =
            doctorSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          String name = data['Name'] as String? ?? '';
          String profilePicture = data['profilePicture'] as String? ?? '';
          String specialization = data['specialization'] as String? ?? '';

          // Create and return the DoctorDetails object
          return DoctorDetails(name, profilePicture, specialization);
        }
      }

      // If the document doesn't exist or has missing details, return null
      return null;
    } catch (e) {
      // Handle errors here (print or throw)
      print('Error fetching DoctorDetails: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Appointments',
          style: GoogleFonts.poppins(letterSpacing: 1),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          itemCount: appointmentsWithDetails.length,
          itemBuilder: (context, index) {
            var appointmentDetails = appointmentsWithDetails[index];
            var doctorName = appointmentDetails.doctorDetails?.name ?? '';
            var profilePictureUrl =
                appointmentDetails.doctorDetails?.profilePicture ?? '';
            var specialization =
                appointmentDetails.doctorDetails?.specialization ?? '';
            var dateTime = appointmentDetails.dateTime;
            var currentStatus = appointmentDetails.currentStatus;
            Widget actionButton;
            if (currentStatus == 'Accepted') {
              actionButton = ElevatedButton(
                onPressed: () {
                  String chatid = _auth.currentUser!.uid.toString();
                  chatid += appointmentDetails.doctorId.toString();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(chatDocumentId: chatid,name: doctorName,),
                    ),
                  );
                },
                child: Text(
                  'Chat with Doctor',
                  style: GoogleFonts.poppins(
                      letterSpacing: 1, color: Colors.black),
                ),
              );
            } else {
              // For status 'Rejected'
              actionButton = SizedBox(); // No button needed for rejected status
            }

            // Determine the card color based on the current status
            Color cardColor =
                currentStatus == 'Rejected' ? Colors.red : Colors.cyan.shade300;

            return GestureDetector(
              onTap: () {
                if (currentStatus == 'Requested') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.cyan.shade300,
                      content: Text(
                        'Waiting for doctor approval\nPlease check after sometime',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            letterSpacing: 1, color: Colors.black),
                      )));
                } else if (currentStatus == 'Rejected'){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.cyan.shade300,
                      content: Text(
                        'Sorry Doctor is unavailable right now,\n Please try another doctor',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            letterSpacing: 1, color: Colors.black),
                      )));
                }
                else if (currentStatus == 'Accepted'){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.cyan.shade300,
                      content: Text(
                        'Click on chat button to continue',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            letterSpacing: 1, color: Colors.black),
                      )));
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.cyan.shade300,
                      content: Text(
                        'Sorry something went wrong\nPlease try again after sometime',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            letterSpacing: 1, color: Colors.black),
                      )));
                }

              },
              child: Card(
                color: cardColor,
                margin: EdgeInsets.all(8.0),
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Dr. " + doctorName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1,
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                specialization,
                                style: GoogleFonts.redHatDisplay(
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              Text(
                                'Time: ${DateFormat('HH:mm').format(dateTime)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Date: ${DateFormat('dd MMM yyyy').format(dateTime)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Current Status: ${currentStatus}',
                                style: TextStyle(color: Colors.white),
                              ),
                              
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                image: (profilePictureUrl.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(profilePictureUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
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
                                  : null,
                            ),
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 8,),
                      actionButton,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String generateInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0].toUpperCase();
      if (nameParts.length > 1) {
        initials += nameParts[1][0].toUpperCase();
      }
    }
    return initials;
  }
}
