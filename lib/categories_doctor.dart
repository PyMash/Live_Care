import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_care/doctor_details._page.dart';
import 'package:live_care/home_page.dart';

class CategoriesDoctor extends StatefulWidget {
  final String documentId;
  const CategoriesDoctor({super.key, required this.documentId});

  @override
  State<CategoriesDoctor> createState() => _CategoriesDoctorState();
}

class _CategoriesDoctorState extends State<CategoriesDoctor> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Doctors',
          style: GoogleFonts.poppins(letterSpacing: 1),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchFeaturedDoctors(),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No featured doctors available'),
              );
            } else {
              var doctors = snapshot.data!;
              var categories = doctors.where((doctor) {
                var specializationString = doctor['specialization'];

                return specializationString == widget.documentId;
              }).toList();

              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var doctor = categories[index];
                  var doctorName = doctor['Name'];
                  var ratingString = doctor['rated'];
                  var profilePictureUrl = doctor['profilePicture'];
                  var specialization = doctor['specialization'];
                  var rating = int.tryParse(ratingString) ?? 0;

                  return GestureDetector(
                    onTap: () {
                      var documentId = doctor['documentId'];
                      print('Clicked on doctor with documentId: $documentId');
                      // Perform additional actions with the document ID as needed
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetails(documentId: documentId),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.cyan.shade300,
                      margin: EdgeInsets.all(8.0),
                      child: Container(
                        height: 220,
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 110, // Set the width to desired size
                                height: 110, // Set the height to desired size
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      10), // Adjust the border radius if needed
                                  image: (profilePictureUrl.isNotEmpty)
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(profilePictureUrl),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dr. "+doctorName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      1, // Add maxLines to limit to a single line
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.045,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  specialization,
                                  style: GoogleFonts.redHatDisplay(
                                    letterSpacing: 1,
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    rating,
                                    (index) => Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width *
                                          0.08,
                                    ),
                                  ),
                                ),
                              ],
                            )
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
    );
  }
}
