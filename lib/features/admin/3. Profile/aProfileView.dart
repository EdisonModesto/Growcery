import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/admin/3.%20Profile/aSettingsSheet.dart';

import '../../../services/AuthService.dart';
import '../../ViewModels/AuthViewModels.dart';
import 'RatingProvider.dart';

class AProfileView extends ConsumerStatefulWidget {
  const AProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AProfileViewState();
}

class _AProfileViewState extends ConsumerState<AProfileView> {
  @override
  Widget build(BuildContext context) {
    var authState = ref.watch(authStateProvider);
    var ratings = ref.watch(ratingsProvider);
    return authState.when(
        data: (data){
          return DefaultTabController(
            length: 4,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: (){
                            showModalBottomSheet(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const ASettingsSheet()
                            );
                          },
                          icon: const Icon(CupertinoIcons.settings),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("assets/images/growceryLogo.jpg"),
                        ),
                        const SizedBox(width: 20,),
                        Text(
                          "Growcery Admin",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            AuthService().signOut();
                          },
                          icon: const Icon(Icons.logout),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Center(
                      child: Text(
                        "Average Rating",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff414141)
                        ),
                      ),
                    ),
                    ratings.when(
                        data: (data){

                          double totalRating = 0;

                          data.docs.forEach((element) {
                            totalRating += element.data()["Rating"];
                          });
                          totalRating = totalRating / data.docs.length;

                          return Center(
                            child: RatingBar.builder(
                              initialRating: totalRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              ignoreGestures: true,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          );
                        },
                        error: (error, stack){
                          return Center(child: Text(error.toString()));
                        },
                        loading: (){
                          return Center(child: const CircularProgressIndicator());
                        }
                    ),


                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stack){
          return Scaffold(
            body: Center(
              child: Text(error.toString()),
            ),
          );
        },
        loading: (){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }
}
