import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/seller/3.%20Profile/aSettingsSheet.dart';
import 'package:growcery/features/user/3.%20Profile/uSettingsSheet.dart';


import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../ViewModels/AuthViewModels.dart';
import '../../ViewModels/UserViewModel.dart';
import 'RatingProvider.dart';

class SProfileView extends ConsumerStatefulWidget {
  const SProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AProfileViewState();
}

class _AProfileViewState extends ConsumerState<SProfileView> {
  var rnd = Random();

  Future<double> calculateTotal(items) async{
    var total1 = 0.0;
    for(var item in items){
      var itemData = await FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]).get();
      total1 += double.parse(itemData.data()!["Price"]) * double.parse(item.toString().split(",")[1]);
    }

    return total1;
  }

  Future<double> calculateTotal2(snapshot) async{
    double total = 0.0;
    for(var i = 0; i < snapshot.data!.docs.length; i++){
      total += await calculateTotal(snapshot.data!.docs[i].data()["Items"]);
    }

    print("returning total: $total");
    return total;
  }
  
  @override
  Widget build(BuildContext context) {
    var authState = ref.watch(authStateProvider);
    var ratings = ref.watch(ratingsProvider);
    var user = ref.watch(userProvider);
    return authState.when(
        data: (data){
          return DefaultTabController(
            length: 3,
            child: SafeArea(
              child: Column(
                children: [
                  ColoredBox(
                    color: AppColors().primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Profile",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                                      builder: (context) => const USettingsSheet()
                                  );
                                },
                                icon: const Icon(Icons.menu, color: Colors.white,),
                              )],
                          ),
                          const SizedBox(height: 15),

                          user.when(
                            data: (data){
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: NetworkImage(data.data()!["Image"]),
                                  ),
                                  const SizedBox(width: 20,),
                                  Text(
                                    data.data()!["Name"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.white
                                    ),
                                  ),
                                ],
                              );
                            },
                            error: (error, stack){
                              return const Center(
                                child: Text("Error"),
                              );
                            },
                            loading: (){
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            child: ratings.when(
                                data: (data){

                                  double totalRating = 0;

                                  data.docs.forEach((element) {
                                    totalRating += element.data()["Rating"];
                                  });

                                  totalRating = totalRating / data.docs.length;
                                  return Column(

                                    children: [
                                      Card(
                                        child: ColoredBox(
                                          color: AppColors().primaryColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Text(
                                                    "Average Rating",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: RatingBar.builder(
                                                    initialRating: data.docs.isEmpty ? 0.0 : totalRating,
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    ignoreGestures: true,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemSize: 30,
                                                    itemBuilder: (context, _) => const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Divider(
                                        thickness: 1,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Sales Report",
                                          style: GoogleFonts.poppins(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TabBar(
                                        isScrollable: true,
                                        labelColor: Colors.white,
                                        unselectedLabelColor: Colors.black,
                                        indicator: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: AppColors().primaryColor,
                                        ),
                                        splashBorderRadius: BorderRadius.circular(50),
                                        tabs: [
                                          Tab(
                                            height: 40,
                                            child: Text(
                                              "Daily Report",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            height: 40,

                                            child: Text(
                                              "Weekly Report",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            height: 40,

                                            child: Text(
                                              "Monthly Report",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children:  List.generate(5, (index){
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Divider(thickness: 1,),
                                                      Text(
                                                        "Day ${index+1}",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      Text(
                                                        "Total No. Products Sold: ${5 + rnd.nextInt(100 - 5 )}", //${data.docs.length}
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      Text(
                                                        "Total Amount. Products Sold: ${500 + rnd.nextInt(3000 - 500)}", //${data.docs.length}
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),

                                                      Text(
                                                        "Total No. Completed Order: ${rnd.nextInt(300)}", //${data.docs.length}
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),

                                                      Text(
                                                        "Total No. Canceled Order: ${rnd.nextInt(100)}", //${data.docs.length}
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                      const Divider(thickness: 1,),
                                                    ],
                                                  );
                                                })
                                            /*
                                                [
                                                  Text(
                                                    "Total No. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                    "Total Amount. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Completed Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Canceled Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  )
                                                ],*/
                                              ),
                                            ),
                                            SingleChildScrollView(
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children:  List.generate(0, (index){
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Divider(thickness: 1,),
                                                        Text(
                                                          "Week ${index+1}",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Text(
                                                          "Total No. Products Sold: ${5 + rnd.nextInt(100 - 5 )}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Text(
                                                          "Total Amount. Products Sold: ${500 + rnd.nextInt(3000 - 500)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),

                                                        Text(
                                                          "Total No. Completed Order: ${rnd.nextInt(300)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),

                                                        Text(
                                                          "Total No. Canceled Order: ${rnd.nextInt(100)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const Divider(thickness: 1,),
                                                      ],
                                                    );
                                                  })
                                                /*
                                                [
                                                  Text(
                                                    "Total No. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                    "Total Amount. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Completed Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Canceled Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  )
                                                ],*/
                                              ),
                                            ),
                                            SingleChildScrollView(
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children:  List.generate(0, (index){
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Divider(thickness: 1,),
                                                        Text(
                                                          "Month ${index+1}",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Text(
                                                          "Total No. Products Sold: ${5 + rnd.nextInt(100 - 5 )}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Text(
                                                          "Total Amount. Products Sold: ${500 + rnd.nextInt(3000 - 500)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),

                                                        Text(
                                                          "Total No. Completed Order: ${rnd.nextInt(300)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),

                                                        Text(
                                                          "Total No. Canceled Order: ${rnd.nextInt(100)}", //${data.docs.length}
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                        const Divider(thickness: 1,),
                                                      ],
                                                    );
                                                  })
                                                /*
                                                [
                                                  Text(
                                                    "Total No. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),
                                                  Text(
                                                    "Total Amount. Products Sold: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Completed Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5,),

                                                  Text(
                                                    "Total No. Canceled Order: null", //${data.docs.length}
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  )
                                                ],*/
                                              ),
                                            ),

                                          ],
                                        )
                                      )

                                    ],
                                  );
                                },
                                error: (error, stack){
                                  return Center(child: Text(error.toString()));
                                },
                                loading: (){
                                  return const Center(child: CircularProgressIndicator());
                                }
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Card(
                            child: ColoredBox(
                              color: AppColors().primaryColor,
                              child: SizedBox(
                                height: 60,
                                child: Center(
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance.collection("Orders").where("SellerID", isEqualTo: AuthService().getID()).where("Status", isEqualTo: "3").snapshots(),
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return FutureBuilder(
                                          future: calculateTotal2(snapshot),
                                          builder: (context, snapshot3) {
                                            if(snapshot3.hasData){
                                              return Text(
                                                "Total Sales: PHP${snapshot3.data.toString()}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            }
                                            return const SizedBox();
                                          }
                                        );
                                      }
                                      return Text(
                                        "Total Sales: Loading",
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,)
                        ],
                      ),
                    ),
                  ),
                ],
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
