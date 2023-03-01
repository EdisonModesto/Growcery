import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/common/OrderDetailsView.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../../services/FirestoreService.dart';
import '../../ViewModels/AuthViewModels.dart';
import '../../ViewModels/OrderViewModel.dart';


class AOrderView extends ConsumerStatefulWidget {
  const AOrderView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AOrderViewState();
}

class _AOrderViewState extends ConsumerState<AOrderView> {

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
          return DefaultTabController(
            length: 4,
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
                          var toPay = data1.docs.where((element) => element.data()["Status"] == "0").toList();
                          var inProgress = data1.docs.where((element) => element.data()["Status"] == "1").toList();
                          var toRecieve = data1.docs.where((element) => element.data()["Status"] == "2").toList();
                          var complete = data1.docs.where((element) => element.data()["Status"] == "3").toList();

                          return TabBarView(
                            children: [
                              ListView.separated(
                                itemCount: toPay.length,
                                itemBuilder: (context, index){
                                  return Container(
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
                                          child: Icon(
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
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: inProgress.length,
                                itemBuilder: (context, index){
                                  return Container(
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
                                          child: Icon(
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
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                              ),
                              ListView.separated(
                                itemCount: toRecieve.length,
                                itemBuilder: (context, index){
                                  return Container(
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
                                          child: Icon(
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
                                      ],
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
                                            child: Icon(
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
