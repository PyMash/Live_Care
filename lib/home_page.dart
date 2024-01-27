import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/categories_doctor.dart';
import 'package:live_care/doctor_details._page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

String generateInitials(String name) {
  List<String> nameParts =
      name.split(' ').where((part) => part.isNotEmpty).toList();
  String initials = '';

  if (nameParts.isNotEmpty) {
    for (int i = 0; i < nameParts.length; i++) {
      initials += nameParts[i][0];
    }
  }

  return initials.toUpperCase();
}

class _HomePageState extends State<HomePage> {
  // Function to fetch featured doctors
  Future<List<Map<String, dynamic>>> fetchFeaturedDoctors() async {
    // Replace 'your_collection_name' with your actual Firestore collection name
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('doctors').get();

    List<Map<String, dynamic>> doctors = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data()!;
      // Include the document ID in the map
      data['documentId'] = doc.id;
      doctors.add(data);
    }

    return doctors;
  }

  String getGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String profilePictureUrl = '';
  late String displayName = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final User? user = _auth.currentUser;
    print(user);

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final fetchedUrl = userDoc['profilePicture'] ?? '';
        print('Fetched Profile Picture URL: $fetchedUrl'); // Debug print
        // print(userDoc['Name']);
        setState(() {
          profilePictureUrl = fetchedUrl ?? ''; // Ensure it's not null
          displayName = userDoc['Name'] ?? '';
        });
      }
    }
  }

  // Function to generate initials from the name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.cyan.shade300,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getGreeting()},',
                        style: GoogleFonts.redHatDisplay(
                          letterSpacing: 1,
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      Text(
                        displayName,
                        style: GoogleFonts.redHatDisplay(
                          letterSpacing: 1,
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      backgroundImage: (profilePictureUrl.isNotEmpty)
                          ? NetworkImage(profilePictureUrl)
                              as ImageProvider<Object>?
                          : null, // Don't specify any image here
                      child: (profilePictureUrl.isEmpty)
                          ? Text(
                              generateInitials(displayName),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            )
                          : null, // Show initials only if there's no image
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 28, left: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find your desired',
                            style: GoogleFonts.montserrat(
                              letterSpacing: 0.5,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                          Text(
                            'Doctor right now',
                            style: GoogleFonts.montserrat(
                              letterSpacing: 1.0,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 25, left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Doctors',
                            style: GoogleFonts.poppins(
                              letterSpacing: 0.5,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.cyan.shade400,
                                content: Text(
                                  'Apologies, but at this time, these are the featured physicians that are available.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      letterSpacing: 1, color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                              ));
                            },
                            child: Text(
                              'See all',
                              style: GoogleFonts.poppins(
                                letterSpacing: 0.5,
                                color: Colors.cyan.shade300,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 25, top: 15),
                    //   child: SizedBox(
                    //     height: MediaQuery.of(context).size.height * 0.22,
                    //     child: FutureBuilder(
                    //       future: fetchFeaturedDoctors(),
                    //       builder: (context,
                    //           AsyncSnapshot<List<Map<String, dynamic>>>
                    //               snapshot) {
                    //         if (snapshot.connectionState ==
                    //             ConnectionState.waiting) {
                    //           return Center(
                    //             child: CircularProgressIndicator(),
                    //           );
                    //         } else if (snapshot.hasError) {
                    //           return Center(
                    //             child: Text('Error: ${snapshot.error}'),
                    //           );
                    //         } else if (!snapshot.hasData ||
                    //             snapshot.data!.isEmpty) {
                    //           return Center(
                    //             child: Text('No featured doctors available'),
                    //           );
                    //         } else {
                    //           var doctors = snapshot.data!;

                    //           return ListView(
                    //             scrollDirection: Axis.horizontal,
                    //             children: doctors.map((doctor) {
                    //               var doctorName = doctor['Name'];
                    //               var ratingString = doctor['rated'];
                    //               var profilePictureUrl =
                    //                   doctor['profilePicture'];
                    //               var specialization =
                    //                   doctor['specialization'];
                    //               var rating = int.tryParse(ratingString) ?? 0;

                    //               return Card(
                    //                 color: Colors.cyan.shade400,
                    //                 margin: EdgeInsets.all(8.0),
                    //                 child: Container(
                    //                   width: MediaQuery.of(context).size.width *
                    //                       0.5,
                    //                   padding: EdgeInsets.all(8.0),
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.center,
                    //                     children: [
                    //                       Padding(
                    //                         padding: const EdgeInsets.symmetric(
                    //                             horizontal: 10),
                    //                         child: CircleAvatar(
                    //                           backgroundColor: Colors.white,
                    //                           radius: 25,
                    //                           backgroundImage: (profilePictureUrl
                    //                                   .isNotEmpty)
                    //                               ? NetworkImage(
                    //                                       profilePictureUrl)
                    //                                   as ImageProvider<Object>?
                    //                               : null, // Don't specify any image here
                    //                           child: (profilePictureUrl.isEmpty)
                    //                               ? Text(
                    //                                   generateInitials(
                    //                                       doctorName),
                    //                                   style: TextStyle(
                    //                                     fontSize: 18,
                    //                                     color: Colors.black,
                    //                                     letterSpacing: 1,
                    //                                   ),
                    //                                 )
                    //                               : null, // Show initials only if there's no image
                    //                         ),
                    //                       ),
                    //                       Padding(
                    //                         padding: const EdgeInsets.all(3.0),
                    //                         child: Text(
                    //                           doctorName,
                    //                           style: GoogleFonts.redHatDisplay(
                    //                               letterSpacing: 1),
                    //                         ),
                    //                       ),
                    //                       Row(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment.center,
                    //                         children: List.generate(
                    //                           rating,
                    //                           (index) => Icon(
                    //                             Icons.star,
                    //                             color: Colors
                    //                                 .amber, // Golden color
                    //                             size: 15,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       Padding(
                    //                         padding: const EdgeInsets.all(1.0),
                    //                         child: Text(
                    //                           specialization,
                    //                           style: GoogleFonts.redHatDisplay(
                    //                               letterSpacing: 1),
                    //                         ),
                    //                       ),

                    //                     ],
                    //                   ),
                    //                 ),
                    //               );
                    //             }).toList(),
                    //           );
                    //         }
                    //       },
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 15),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.22,
                        child: FutureBuilder(
                          future: fetchFeaturedDoctors(),
                          builder: (context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('No featured doctors available'),
                              );
                            } else {
                              var doctors = snapshot.data!;
                              var fiveStarDoctors = doctors.where((doctor) {
                                var ratingString = doctor['rated'];
                                var rating = int.tryParse(ratingString) ?? 0;
                                return rating == 5;
                              }).toList();

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: fiveStarDoctors.length,
                                itemBuilder: (context, index) {
                                  var doctor = fiveStarDoctors[index];
                                  var doctorName = doctor['Name'];
                                  var ratingString = doctor['rated'];
                                  var profilePictureUrl =
                                      doctor['profilePicture'];
                                  var specialization = doctor['specialization'];
                                  var rating = int.tryParse(ratingString) ?? 0;

                                  return GestureDetector(
                                    onTap: () {
                                      var documentId = doctor['documentId'];
                                      print(
                                          'Clicked on doctor with documentId: $documentId');
                                      // Perform additional actions with the document ID as needed
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDetails(documentId: documentId),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.cyan.shade400,
                                      margin: EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 25,
                                                backgroundImage:
                                                    (profilePictureUrl
                                                            .isNotEmpty)
                                                        ? NetworkImage(
                                                            profilePictureUrl)
                                                        : null,
                                                child: (profilePictureUrl
                                                        .isEmpty)
                                                    ? Text(
                                                        generateInitials(
                                                            doctorName),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          letterSpacing: 1,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                doctorName,
                                                style:
                                                    GoogleFonts.redHatDisplay(
                                                        letterSpacing: 1),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                rating,
                                                (index) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Text(
                                                specialization,
                                                style:
                                                    GoogleFonts.redHatDisplay(
                                                        letterSpacing: 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: GoogleFonts.poppins(
                              letterSpacing: 0.5,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.cyan.shade400,
                                content: Text(
                                  'Apologies, but at this time, these are the only categories available',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      letterSpacing: 1, color: Colors.black),
                                ),
                                duration: Duration(seconds: 2),
                              ));
                            },
                            child: Text(
                              'View all',
                              style: GoogleFonts.poppins(
                                letterSpacing: 0.5,
                                color: Colors.cyan.shade300,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.32,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: [
                            _buildSpecialtyItem(
                                'Dermatology', Icons.accessibility_new, () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Dermatology"),
                                        ),
                                      );
                            }),
                            _buildSpecialtyItem(
                                'Ophthalmology', Icons.remove_red_eye, () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Ophthalmology"),
                                        ),
                                      );
                            }),
                            _buildSpecialtyItem(
                                'Neurology', Icons.sentiment_very_satisfied,
                                () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Neurology"),
                                        ),
                                      );
                            }),
                            _buildSpecialtyItem(
                                'Orthopedics', Icons.elderly_woman_sharp, () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Orthopedics"),
                                        ),
                                      );
                            }),
                            _buildSpecialtyItem(
                                'Gynecology', Icons.pregnant_woman, () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Gynecology"),
                                        ),
                                      );
                            }),
                            _buildSpecialtyItem('Cardiology', Icons.favorite,
                                () {
                                  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoriesDoctor(documentId:"Cardiology"),
                                        ),
                                      );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyItem(
      String name, IconData iconData, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.cyan.shade300,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 3),
            Text(name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(letterSpacing: 1, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
