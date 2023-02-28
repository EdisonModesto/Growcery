import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/ViewModels/UserViewModel.dart';
import 'package:growcery/services/FirestoreService.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';

class UBasketView extends ConsumerStatefulWidget {
  const UBasketView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UBasketViewState();
}

class _UBasketViewState extends ConsumerState<UBasketView> {
  // double total = 0.0;

  List<int> itemQuantity = List.filled(100, 1);
  List<double> itemPrice = List.filled(100, 0);

  double total = 0.0;

  Future<double> loadTotal() async {
    await Future.delayed(Duration(seconds: 1));
    return total;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var basket = ref.watch(userProvider);
    total = 0.0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: basket.when(data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Basket",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                  child: ListView.separated(
                itemCount: data.data()!["Basket"].length,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Items")
                        .doc(data
                            .data()!["Basket"][index]
                            .toString()
                            .split(",")[0])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        itemQuantity[index] = int.parse(data
                            .data()!["Basket"][index]
                            .toString()
                            .split(",")[1]);
                        itemPrice[index] = double.parse(
                            snapshot.data!.data()!["Price"].toString());
                        return Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        snapshot.data!.data()!["Url"]),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.data()!["Name"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      snapshot.data!
                                          .data()!["Description"]
                                          .toString()
                                          .substring(0, 14),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "PHP ${snapshot.data!.data()!["Price"]}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  FirestoreService().updateBasketQuantity(
                                      data
                                          .data()!["Basket"][index]
                                          .toString()
                                          .split(",")[0],
                                      itemQuantity[index] - 1,
                                      data.data()!["Basket"][index]);
                                  itemQuantity[index] = itemQuantity[index] - 1;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors().primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "${itemQuantity[index]}",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  FirestoreService().updateBasketQuantity(
                                      data
                                          .data()!["Basket"][index]
                                          .toString()
                                          .split(",")[0],
                                      itemQuantity[index] + 1,
                                      data.data()!["Basket"][index]);
                                  itemQuantity[index] = itemQuantity[index] + 1;
                                  print(itemQuantity[index]);
                                  setState(() {});
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors().primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
              )),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: PriceLabel(
                    prices: itemPrice,
                    quantity: itemQuantity,
                    items: data.data()!["Basket"],
                  ),
                ),
              )
            ],
          );
        }, error: (error, stack) {
          return Center(
            child: Text(
              error.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }, loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      ),
    );
  }
}

class PriceLabel extends ConsumerStatefulWidget {
  const PriceLabel({
    required this.prices,
    required this.quantity,
    required this.items,
    Key? key,
  }) : super(key: key);

  final List<double> prices;
  final List<int> quantity;
  final List<dynamic> items;

  @override
  ConsumerState createState() => _PriceLabelState();
}

class _PriceLabelState extends ConsumerState<PriceLabel> {
  Future<double> computeTotal() async {
    await Future.delayed(const Duration(seconds: 1));
    double total = 0;
    for (int i = 0; i < widget.prices.length; i++) {
      total = total + (widget.prices[i] * widget.quantity[i]);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: (){
              FirestoreService().createOrder(widget.items);
            },
            child: Container(
              height: 55,
              color: AppColors().primaryColor,
              child: Center(
                child: Text(
                  "Checkout",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          color: Colors.white,
        ),
        Expanded(
          child: FutureBuilder(
              future: computeTotal(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "Total: PHP ${snapshot.data}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  );
                }
                return const SizedBox();
              }),
        ),
      ],
    );
  }
}
