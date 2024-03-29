import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";
import "package:growcery/common/AuthView.dart";
import "package:growcery/constants/AppColors.dart";
import "package:growcery/features/ViewModels/OrderViewModel.dart";
import "package:growcery/features/user/3.%20Profile/uEditProfileDialog.dart";
import "package:growcery/features/user/3.%20Profile/uSettingsSheet.dart";
import "package:growcery/services/FirestoreService.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";

import "../../../common/OrderDetailsView.dart";
import '../../../common/ViewItemSheet.dart';
import "../../../services/AuthService.dart";
import "../../ViewModels/AuthViewModels.dart";
import "../../ViewModels/UserViewModel.dart";
import "RatingSheet.dart";
import "RefundSheet.dart";

class UProfileView extends ConsumerStatefulWidget {
  const UProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UOrderViewState();
}

class _UOrderViewState extends ConsumerState<UProfileView> {

  Future<double> calculateTotal(items) async {
    var total = 0.0;
    for (var item in items) {
      var itemData = await FirebaseFirestore.instance.collection("Items").doc(
          item.toString().split(",")[0]).get();
      total += double.parse(itemData.data()!["Price"]) *
          int.parse(items.toString().split(",")[1]);
    }

    return total;
  }

  Future<Map<String, dynamic>?> getResource(id) async {
    var snapshot = await FirebaseFirestore.instance.collection("Items")
        .doc(id)
        .get();
    return snapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    var authState = ref.watch(authStateProvider);
    var orders = ref.watch(orderProvider);

    return authState.when(
        data: (data) {
          var user = ref.watch(userProvider);

          return DefaultTabController(
            length: 6,
            child: SafeArea(
              child: SizedBox(
                child: Column(
                  children: [
                    Container(
                      color: AppColors().primaryColor,
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Profile",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Visibility(
                                visible: data?.uid == null ? false : true,
                                child: IconButton(
                                  onPressed: () {
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
                                  icon: const Icon(
                                    Icons.menu, color: Colors.white,),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          user.when(
                              data: (data1) {
                                return ColoredBox(
                                  color: AppColors().primaryColor,
                                  child: Row(
                                    children: [
                                      data?.uid == null ? const CircleAvatar(
                                        radius: 35,
                                        child: Icon(Icons.person),
                                      ) :
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundImage: data1
                                            .data()!["Image"] == ""
                                            ?
                                        const NetworkImage(
                                            "http://via.placeholder.com/300x300")
                                            :
                                        NetworkImage(data1.data()!["Image"]),
                                        backgroundColor: AppColors()
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 20,),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  data?.uid == null
                                                      ? "Login to continue"
                                                      : data1.data()!["Name"],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            data?.uid == null ? ElevatedButton(
                                              onPressed: () async {
                                                context.go("/auth");
                                              },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: AppColors()
                                                    .primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(10),
                                                ),
                                                padding: const EdgeInsets
                                                    .fromLTRB(20, 10, 20, 10),
                                              ),
                                              child: Text(
                                                "Login or Signup",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,

                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ) :
                                            const SizedBox(),
                                          ]
                                      )
                                    ],
                                  ),
                                );
                              },
                              error: (error, stack) {
                                return const Center(
                                  child: Text("Error"),
                                );
                              },
                              loading: () {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

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
                                    "Cancelled",
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
                                Tab(
                                  child: Text(
                                    "Refund",
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
                                data: (data1) {
                                  var userID = AuthService().getID();
                                  var toPay = data1.docs.where((element) => element.data()["Status"] == "0" && element.data()["User"] == userID).toList();
                                  var inProgress = data1.docs.where((element) => element.data()["Status"] == "1" && element.data()["User"] == userID).toList();
                                  var toRecieve = data1.docs.where((element) => element.data()["Status"] == "2" && element.data()["User"] == userID).toList();
                                  var complete = data1.docs.where((element) => element.data()["Status"] == "3" && element.data()["User"] == userID).toList();
                                  var cancelled = data1.docs.where((element) => element.data()["Status"] == "4" && element.data()["User"] == userID).toList();
                                  var refunded = data1.docs.where((element) => element.data()["Status"] == "5" && element.data()["User"] == userID).toList();

                                  toPay.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                                  inProgress.sort(( a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                                  toRecieve.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                                  complete.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                                  cancelled.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                                  refunded.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));

                                  return TabBarView(
                                    children: [
                                      ListView.separated(
                                        itemCount: toPay.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(toPay[index]
                                                  .data()["Items"][0]
                                                  .toString()
                                                  .split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: toPay[index],
                                                              isComplete: false,
                                                              delivery: false,

                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: AppColors()
                                                                  .primaryColor,
                                                              borderRadius: BorderRadius
                                                                  .circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(
                                                                    snapshot
                                                                        .data!["Url"]),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  toPay[index]
                                                                      .id,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  "Total Items: ${toPay[index]
                                                                      .data()["Items"]
                                                                      .length}",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    color: Colors.white,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        toPay[index]
                                                                            .data()["Items"]),
                                                                    builder: (
                                                                        context,
                                                                        result) {
                                                                      if (result
                                                                          .hasData) {
                                                                        return Text(
                                                                          "Total Price: ${result
                                                                              .data}",
                                                                          style: GoogleFonts
                                                                              .poppins(
                                                                            fontSize: 12,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                          ),
                                                                        );
                                                                      }
                                                                      return const SizedBox();
                                                                    }
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                                                            onPressed: () async {
                                                              await showDialog(context: context, builder: (builder){
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    "Cancel Order",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  content: Text(
                                                                    "Are you sure you want to cancel this order?",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: (){
                                                                        Navigator.of(builder).pop();
                                                                      },
                                                                      child: Text(
                                                                        "No",
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: (){
                                                                        FirestoreService().updateOrderStatus(toPay[index].id, "4");
                                                                        //restore stock
                                                                        for(var i = 0; i < toPay[index].data()["Items"].length; i++){
                                                                          FirestoreService().restoreStock(toPay[index].data()["Items"][i].toString().split(",")[0], toPay[index].data()["Items"][i].toString().split(",")[1]);
                                                                        }
                                                                        Navigator.pop(builder);
                                                                      },
                                                                      child: Text(
                                                                        "Yes",
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),
                                      ListView.separated(
                                        itemCount: inProgress.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(
                                                  inProgress[index]
                                                      .data()["Items"][0]
                                                      .toString()
                                                      .split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: inProgress[index],
                                                              isComplete: false,
                                                              delivery: false,

                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: AppColors()
                                                                  .primaryColor,
                                                              borderRadius: BorderRadius
                                                                  .circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(
                                                                    snapshot
                                                                        .data!["Url"]),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  inProgress[index]
                                                                      .id,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  "Total Items: ${inProgress[index]
                                                                      .data()["Items"]
                                                                      .length}",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    color: Colors.white,
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        inProgress[index]
                                                                            .data()["Items"]),
                                                                    builder: (
                                                                        context,
                                                                        result) {
                                                                      if (result
                                                                          .hasData) {
                                                                        return Text(
                                                                          "Total Price: ${result
                                                                              .data}",
                                                                          style: GoogleFonts
                                                                              .poppins(
                                                                            fontSize: 12,
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                          ),
                                                                        );
                                                                      }
                                                                      return const SizedBox();
                                                                    }
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),

                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),
                                      ListView.separated(
                                        itemCount: toRecieve.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(
                                                  toRecieve[index]
                                                      .data()["Items"][0]
                                                      .toString()
                                                      .split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: toRecieve[index],
                                                              isComplete: false,
                                                              delivery: true,
                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                        Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          color: AppColors()
                                                              .primaryColor,
                                                          borderRadius: BorderRadius
                                                              .circular(10),
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                                snapshot
                                                                    .data!["Url"]),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Text(
                                                              toRecieve[index]
                                                                  .id,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight
                                                                    .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              "Total Items: ${toRecieve[index]
                                                                  .data()["Items"]
                                                                  .length}",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight
                                                                    .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            FutureBuilder(
                                                                future: calculateTotal(
                                                                    toRecieve[index]
                                                                        .data()["Items"]),
                                                                builder: (
                                                                    context,
                                                                    result) {
                                                                  if (result
                                                                      .hasData) {
                                                                    return Text(
                                                                      "Total Price: ${result
                                                                          .data}",

                                                                      style: GoogleFonts
                                                                          .poppins(
                                                                        fontSize: 12,
                                                                        color: Colors.white,

                                                                        fontWeight: FontWeight
                                                                            .w400,
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
                                                            icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                                                            onPressed: () async {
                                                              await showDialog(context: context, builder: (builder){
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    "Cancel Order",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  content: Text(
                                                                    "Are you sure you want to cancel this order?",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: (){
                                                                        Navigator.of(builder).pop();
                                                                      },
                                                                      child: Text(
                                                                        "No",
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: (){
                                                                        FirestoreService().updateOrderStatus(toPay[index].id, "4");
                                                                        //restore stock
                                                                        for(var i = 0; i < toPay[index].data()["Items"].length; i++){
                                                                          FirestoreService().restoreStock(toPay[index].data()["Items"][i].toString().split(",")[0], toPay[index].data()["Items"][i].toString().split(",")[1]);
                                                                        }
                                                                        Navigator.pop(builder);
                                                                      },
                                                                      child: Text(
                                                                        "Yes",
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                            },
                                                          ),
                                                          IconButton(
                                                        onPressed: () {
                                                          print(toRecieve[index]);
                                                          showMaterialModalBottomSheet(
                                                              context: context,
                                                              shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.vertical(
                                                                  top: Radius.circular(20),
                                                                ),
                                                              ),
                                                              isDismissible: false,
                                                              builder: (context){
                                                                return RatingSheet(
                                                                  orderData: toRecieve[index],
                                                                );
                                                              }
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          CupertinoIcons.cube_box,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      ],
                                                    ),
                                                  ),);
                                              }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),
                                      ListView.separated(
                                        itemCount: cancelled.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(
                                                  cancelled[index].data()["Items"][0].toString().split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: cancelled[index],
                                                              isComplete: false,
                                                              delivery: false,

                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: AppColors().primaryColor,
                                                              borderRadius: BorderRadius.circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(
                                                                    snapshot.data!["Url"]),
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  cancelled[index].id,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  "Total Items: ${cancelled[index].data()["Items"].length}",
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 12,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        cancelled[index].data()["Items"]),
                                                                    builder: (context, result) {
                                                                      if (result.hasData) {
                                                                        return Text(
                                                                          "Total Price: ${result.data}",
                                                                          style: GoogleFonts.poppins(
                                                                            fontSize: 12,
                                                                            color: Colors.white,

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
                                                    ),);
                                                }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),
                                      ListView.separated(
                                        itemCount: complete.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(
                                                  complete[index].data()["Items"][0].toString().split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: complete[index],
                                                              isComplete: true,
                                                              delivery: false,

                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: AppColors()
                                                                  .primaryColor,
                                                              borderRadius: BorderRadius
                                                                  .circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(
                                                                    snapshot
                                                                        .data!["Url"]),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  complete[index]
                                                                      .id,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  "Total Items: ${complete[index]
                                                                      .data()["Items"]
                                                                      .length}",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 12,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        complete[index]
                                                                            .data()["Items"]),
                                                                    builder: (
                                                                        context,
                                                                        result) {
                                                                      if (result
                                                                          .hasData) {
                                                                        return Text(
                                                                          "Total Price: ${result
                                                                              .data}",
                                                                          style: GoogleFonts
                                                                              .poppins(
                                                                            fontSize: 12,
                                                                            color: Colors.white,

                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                          ),
                                                                        );
                                                                      }
                                                                      return const SizedBox();
                                                                    }
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              showMaterialModalBottomSheet(
                                                                context: context,
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(20),
                                                                    topRight: Radius.circular(20),
                                                                  ),
                                                                ),
                                                                builder: (context) => RefundSheet(
                                                                  orderData: complete[index],
                                                                ),
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              CupertinoIcons.return_icon,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),
                                      ListView.separated(
                                        itemCount: refunded.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder(
                                              future: getResource(
                                                  refunded[index]
                                                      .data()["Items"][0]
                                                      .toString()
                                                      .split(",")[0]),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .vertical(
                                                              top: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          builder: (context) {
                                                            return OrderDetailsView(
                                                              orderData: refunded[index],
                                                              isComplete: false,
                                                              delivery: false,
                                                            );
                                                          }
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: AppColors().primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: AppColors()
                                                                  .primaryColor,
                                                              borderRadius: BorderRadius
                                                                  .circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(
                                                                    snapshot
                                                                        .data!["Url"]),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              crossAxisAlignment: CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  refunded[index]
                                                                      .id,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  "Total Items: ${refunded[index]
                                                                      .data()["Items"]
                                                                      .length}",
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize: 12,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(
                                                                        refunded[index]
                                                                            .data()["Items"]),
                                                                    builder: (
                                                                        context,
                                                                        result) {
                                                                      if (result
                                                                          .hasData) {
                                                                        return Text(
                                                                          "Total Price: ${result
                                                                              .data}",
                                                                          style: GoogleFonts
                                                                              .poppins(
                                                                            fontSize: 12,
                                                                            color: Colors.white,

                                                                            fontWeight: FontWeight
                                                                                .w400,
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
                                                }
                                                return const SizedBox();
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                      ),

                                    ],
                                  );
                                },
                                error: (error, stack) {
                                  return Center(
                                    child: Text(error.toString()),
                                  );
                                },
                                loading: () {
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
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stack) {
          return Scaffold(
            body: Center(
              child: Text(error.toString()),
            ),
          );
        },
        loading: () {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }
}
