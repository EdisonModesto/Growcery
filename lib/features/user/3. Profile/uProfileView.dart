import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:growcery/common/AuthView.dart";
import "package:growcery/constants/AppColors.dart";
import "package:growcery/features/ViewModels/OrderViewModel.dart";
import "package:growcery/features/user/3.%20Profile/uEditProfileDialog.dart";
import "package:growcery/services/FirestoreService.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

import "../../../common/OrderDetailsView.dart";
import '../../../common/ViewItemSheet.dart';
import "../../../services/AuthService.dart";
import "../../ViewModels/AuthViewModels.dart";
import "../../ViewModels/UserViewModel.dart";

class UProfileView extends ConsumerStatefulWidget {
  const UProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UOrderViewState();
}

class _UOrderViewState extends ConsumerState<UProfileView> {

  Future<double> calculateTotal(items) async{
    var total = 0.0;
    for(var item in items){
      var itemData = await FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]).get();
      total += double.parse(itemData.data()!["Price"]) * int.parse(items.toString().split(",")[1]);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {

    var authState = ref.watch(authStateProvider);
    var orders = ref.watch(orderProvider);

    return authState.when(
      data: (data){
        var user = ref.watch(userProvider);

        return DefaultTabController(
          length: 4,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  user.when(
                    data: (data1){
                      return Row(
                        children: [
                          data?.uid == null ? const CircleAvatar(
                            radius: 35,
                            child: Icon(Icons.person),
                          ) :
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: data1.data()!["Image"] == "" ?
                            const NetworkImage("http://via.placeholder.com/300x300") :
                            NetworkImage(data1.data()!["Image"]),
                            backgroundColor: AppColors().primaryColor,
                          ),
                          const SizedBox(width: 20,),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data?.uid == null ? "Login to continue" : data1.data()!["Name"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Visibility(
                                      visible: data?.uid == null ? false : true,
                                      child: IconButton(
                                        onPressed: (){
                                          AuthService().signOut();
                                        },
                                        icon: const Icon(Icons.logout),
                                      ),
                                    )
                                  ],
                                ),
                                data?.uid == null ? ElevatedButton(
                                  onPressed: ()async{
                                    context.go("/auth");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors().primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  ),
                                  child: Text(
                                    "Login or Signup",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ) : ElevatedButton(
                                  onPressed: (){
                                    showDialog(context: context, builder: (builder){
                                      return UEditProfileDialog(data: data1);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors().primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  ),
                                  child: Text(
                                    "Edit Profile",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ]
                          )
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
                    }
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  const SizedBox(height: 10),
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
                        child: Text(
                          "To Pay",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "In Progress",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "To Receive",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Completed",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: data?.uid == null ? Center(
                      child: Text(
                        "Login to continue",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ) :

                        orders.when(
                          data: (data1){
                            var userID = AuthService().getID();
                            var toPay = data1.docs.where((element) => element.data()["Status"] == "0" && element.data()["User"] == userID).toList();
                            var inProgress = data1.docs.where((element) => element.data()["Status"] == "1" && element.data()["User"] == userID).toList();
                            var toRecieve = data1.docs.where((element) => element.data()["Status"] == "2" && element.data()["User"] == userID).toList();
                            var complete = data1.docs.where((element) => element.data()["Status"] == "3" && element.data()["User"] == userID).toList();

                            return TabBarView(
                              children: [
                                ListView.separated(
                                  itemCount: toPay.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){
                                        showMaterialModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context){
                                              return OrderDetailsView(
                                                orderData: toPay[index],
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: AppColors().primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.money_dollar_circle,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    toPay[index].id,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Total Items: ${toPay[index].data()["Items"].length}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  FutureBuilder(
                                                      future: calculateTotal(toPay[index].data()["Items"]),
                                                      builder: (context, result) {
                                                        if(result.hasData){
                                                          return Text(
                                                            "Total Price: ${result.data}",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      }
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                ),
                                ListView.separated(
                                  itemCount: inProgress.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){
                                        showMaterialModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context){
                                              return OrderDetailsView(
                                                orderData: inProgress[index],
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: AppColors().primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.cube_box,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    inProgress[index].id,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Total Items: ${inProgress[index].data()["Items"].length}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  FutureBuilder(
                                                      future: calculateTotal(inProgress[index].data()["Items"]),
                                                      builder: (context, result) {
                                                        if(result.hasData){
                                                          return Text(
                                                            "Total Price: ${result.data}",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      }
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                ),
                                ListView.separated(
                                  itemCount: toRecieve.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){
                                        showMaterialModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context){
                                              return OrderDetailsView(
                                                orderData: toRecieve[index],
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: AppColors().primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.receipt_long_outlined,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    toRecieve[index].id,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Total Items: ${toRecieve[index].data()["Items"].length}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  FutureBuilder(
                                                      future: calculateTotal(toRecieve[index].data()["Items"]),
                                                      builder: (context, result) {
                                                        if(result.hasData){
                                                          return Text(
                                                            "Total Price: ${result.data}",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      }
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              onPressed:(){
                                                FirestoreService().updateOrderStatus(toRecieve[index].id, "3");
                                              },
                                              icon: const Icon(
                                                CupertinoIcons.cube_box,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                ),
                                ListView.separated(
                                  itemCount: complete.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){
                                        showMaterialModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context){
                                              return OrderDetailsView(
                                                orderData: complete[index],
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: AppColors().primaryColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.check_mark_circled,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    complete[index].id,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Total Items: ${complete[index].data()["Items"].length}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  FutureBuilder(
                                                      future: calculateTotal(complete[index].data()["Items"]),
                                                      builder: (context, result) {
                                                        if(result.hasData){
                                                          return Text(
                                                            "Total Price: ${result.data}",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          );
                                                        }
                                                        return const SizedBox();
                                                      }
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                ),
                              ],
                            );
                          },
                          error: (error, stack){
                            return Center(
                              child: Text(error.toString()),
                            );
                          },
                          loading: (){
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
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
