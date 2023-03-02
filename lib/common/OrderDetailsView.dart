import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsView extends ConsumerStatefulWidget {
  const OrderDetailsView({
    required this.orderData,
    Key? key,
  }) : super(key: key);

  final orderData;

  @override
  ConsumerState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends ConsumerState<OrderDetailsView> {

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
    return SizedBox(
      height: 600,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Details",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Order ID:",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.orderData.id,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Items:",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                itemCount: widget.orderData.data()['Items'].length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('Items')
                        .doc(widget.orderData.data()['Items'][index].toString().split(",")[0])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          children: [
                            Text(
                              snapshot.data!['Name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "x${widget.orderData.data()['Items'][index].toString().split(",")[1]}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  );

                    Row(
                    children: [
                      Text(
                        widget.orderData.data()['Items'][index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "x${widget.orderData.data()['Items'][index]}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Total:",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder(
                    future: calculateTotal(widget.orderData.data()['Items']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "PHP${snapshot.data}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
