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
                            builder: (context) => USettingsSheet()
                        );
                      },
                      icon: const Icon(CupertinoIcons.settings),
                    )],
                  ),
                    const SizedBox(height: 15),

                    user.when(
                      data: (data){
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(data.data()!["Image"]),
                            ),
                            const SizedBox(width: 20,),
                            Text(
                              data.data()!["Name"],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
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
                    const SizedBox(height: 20),
                    const Divider(),
                    Center(
                      child: Text(
                        "Average Rating",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff414141)
                        ),
                      ),
                    ),
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
                                Center(
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
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ListView.builder(
                                  itemCount: data.docs.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index){
                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection("Users").doc(data.docs[index].data()["MarketName"]).snapshots(),
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData){
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: AppColors().primaryColor,
                                              radius: 20,
                                              child: Text(
                                                data.docs[index].data()["Rating"].toString(),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              snapshot.data!.data()!["Name"],
                                              //data.docs[index].data()["Name"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: RatingBar.builder(
                                              initialRating: double.parse(data.docs[index].data()["Rating"].toString()),
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              ignoreGestures: true,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding: const EdgeInsets.symmetric(horizontal:0),
                                              itemSize: 25,
                                              itemBuilder: (context, _) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),

                                          );
                                        }
                                        return SizedBox();
                                      }
                                    );
                                  },
                                )
                              ],
                            );
                          },
                          error: (error, stack){
                            return Center(child: Text(error.toString()));
                          },
                          loading: (){
                            return Center(child: const CircularProgressIndicator());
                          }
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: SizedBox(
                          height: 100,
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      return SizedBox();
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
                      )
                    )
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
