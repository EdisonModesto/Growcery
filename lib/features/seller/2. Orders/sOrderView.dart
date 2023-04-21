import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/common/OrderDetailsView.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../../services/FirestoreService.dart';
import '../../ViewModels/AuthViewModels.dart';
import '../../ViewModels/OrderViewModel.dart';


class SOrderView extends ConsumerStatefulWidget {
  const SOrderView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AOrderViewState();
}

class _AOrderViewState extends ConsumerState<SOrderView> {

  Future<double> calculateTotal(items) async{
    var total = 0.0;
    for(var item in items){
      var itemData = await FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]).get();
      total += double.parse(itemData.data()!["Price"]) * int.parse(items.toString().split(",")[1]);
    }

    return total;
  }

  Future<Map<String, dynamic>?> getResource(id) async {
    var snapshot = await FirebaseFirestore.instance.collection("Items").doc(id).get();
    return snapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    var authState = ref.watch(authStateProvider);
    var orders = ref.watch(orderProvider);

    return authState.when(
        data: (data){
          return DefaultTabController(
            length: 5,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Orders",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

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
                            "Order List",
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
                            "For Delivery",
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
                        data: (data1){
                          var toPay = data1.docs.where((element) => element.data()["Status"] == "0" && element.data()["SellerID"] == AuthService().getID()).toList();
                          var inProgress = data1.docs.where((element) => element.data()["Status"] == "1" && element.data()["SellerID"] == AuthService().getID()).toList();
                          var toRecieve = data1.docs.where((element) => element.data()["Status"] == "2" && element.data()["SellerID"] == AuthService().getID()).toList();
                          var complete = data1.docs.where((element) => element.data()["Status"] == "3" && element.data()["SellerID"] == AuthService().getID()).toList();
                          var canceled = data1.docs.where((element) => element.data()["Status"] == "5" && element.data()["SellerID"] == AuthService().getID()).toList();

                          toPay.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                          inProgress.sort(( a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                          toRecieve.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                          complete.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));
                          canceled.sort((a, b) => b.data()["Date"].compareTo(a.data()["Date"]));

                          return TabBarView(
                            children: [
                              ListView.separated(
                                itemCount: toPay.length,
                                itemBuilder: (context, index){
                                  return FutureBuilder(
                                    future: getResource(toPay[index].data()["Items"][0].toString().split(",")[0]),
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return FutureBuilder(
                                          future: FirebaseFirestore.instance.collection("Users").doc(toPay[index].data()["User"]).get(),
                                          builder: (context, snapshot1) {
                                            if(snapshot1.hasData){
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
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[200],
                                                          borderRadius: BorderRadius.circular(10),
                                                          image: DecorationImage(
                                                            image: NetworkImage(snapshot1.data!["Image"] == "" ? snapshot.data!["Url"] : snapshot1.data!["Image"]),
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
                                                              snapshot1.data!["Name"],
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 5),
                                                            Text(
                                                              "Total Items: ${toPay[index].data()["Items"].length}",
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color: Colors.white,

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
                                                      const SizedBox(width: 10),
                                                      IconButton(
                                                        onPressed:(){
                                                          FirestoreService().updateOrderStatus(toPay[index].id, "4");
                                                        },
                                                        icon: const Icon(
                                                          CupertinoIcons.xmark_octagon,
                                                          color: Colors.white,

                                                          size: 30,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      IconButton(
                                                        onPressed:(){
                                                          FirestoreService().updateOrderStatus(toPay[index].id, "1");
                                                        },
                                                        icon: const Icon(
                                                          CupertinoIcons.checkmark_alt_circle,
                                                          color: Colors.white,

                                                          size: 30,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                            return SizedBox();
                                          }
                                        );
                                      }
                                      return SizedBox();
                                    }
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: inProgress.length,
                                itemBuilder: (context, index){
                                  return FutureBuilder(
                                      future: getResource(inProgress[index].data()["Items"][0].toString().split(",")[0]),
                                      builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return FutureBuilder(
                                            future: FirebaseFirestore.instance.collection("Users").doc(inProgress[index].data()["User"]).get(),
                                            builder: (context, snapshot1) {
                                              if(snapshot1.hasData){
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
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[200],
                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(
                                                              image: NetworkImage(snapshot1.data!["Image"]),
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
                                                                snapshot1.data!["Name"],
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Colors.white,

                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                "Total Items: ${inProgress[index].data()["Items"].length}",
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  color: Colors.white,

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
                                                        const SizedBox(width: 10),
                                                        IconButton(
                                                          onPressed:(){
                                                            FirestoreService().updateOrderStatus(inProgress[index].id, "2");
                                                          },
                                                          icon: const Icon(
                                                            CupertinoIcons.upload_circle,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );

                                              }
                                              return SizedBox();
                                          }
                                        );
                                      }
                                      return const SizedBox();
                                    }
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: toRecieve.length,
                                itemBuilder: (context, index){
                                  return FutureBuilder(
                                      future: getResource(toRecieve[index].data()["Items"][0].toString().split(",")[0]),
                                      builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return FutureBuilder(
                                            future: FirebaseFirestore.instance.collection("Users").doc(toRecieve[index].data()["User"]).get(),
                                            builder: (context, snapshot1) {
                                              if(snapshot1.hasData){
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
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[200],

                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(
                                                              image: NetworkImage(snapshot1.data!["Image"]),
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
                                                                snapshot1.data!["Name"],
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Colors.white,

                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                "Total Items: ${toRecieve[index].data()["Items"].length}",
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  color: Colors.white,

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
                                                  ),
                                                );

                                              }
                                              return SizedBox();
                                            }
                                        );
                                      }
                                      return const SizedBox();
                                    }
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: complete.length,
                                itemBuilder: (context, index){
                                  return FutureBuilder(
                                      future: getResource(complete[index].data()["Items"][0].toString().split(",")[0]),
                                      builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return FutureBuilder(
                                            future: FirebaseFirestore.instance.collection("Users").doc(complete[index].data()["User"]).get(),
                                            builder: (context, snapshot1) {
                                              if(snapshot1.hasData){
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
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey[200],

                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(
                                                              image: NetworkImage(snapshot1.data!["Image"]),
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
                                                                snapshot1.data!["Name"],
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Colors.white,

                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                "Total Items: ${complete[index].data()["Items"].length}",
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  color: Colors.white,

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
                                                  ),
                                                );
                                              }
                                              return SizedBox();
                                            }
                                        );
                                      }
                                      return const SizedBox();
                                    }
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: canceled.length,
                                itemBuilder: (context, index){
                                  return FutureBuilder(
                                      future: getResource(canceled[index].data()["Items"][0].toString().split(",")[0]),
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData){
                                          return FutureBuilder(
                                              future: FirebaseFirestore.instance.collection("Users").doc(canceled[index].data()["User"]).get(),
                                              builder: (context, snapshot1) {
                                                if (snapshot1.hasData) {
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
                                                              orderData: canceled[index],
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
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius: BorderRadius.circular(10),
                                                              image: DecorationImage(
                                                                image: NetworkImage(snapshot1.data!["Image"]),
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
                                                                  snapshot1.data!["Name"],
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 14,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                Text(
                                                                  "Total Items: ${canceled[index].data()["Items"].length}",
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 12,
                                                                    color: Colors.white,

                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                FutureBuilder(
                                                                    future: calculateTotal(canceled[index].data()["Items"]),
                                                                    builder: (context, result) {
                                                                      if(result.hasData){
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
                                                    ),
                                                  );
                                                }
                                                return SizedBox();
                                            }
                                          );
                                        }
                                        return const SizedBox();
                                      }
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
