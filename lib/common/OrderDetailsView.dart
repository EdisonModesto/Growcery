import 'package:auto_size_text/auto_size_text.dart';
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
      total += double.parse(itemData.data()!["Price"]) * double.parse(item.toString().split(",")[1]);
    }

    var brgy = widget.orderData.data()['Address'].toString().split("%")[1];

    if (brgy == "San Isidro") {
      total += 200;
    } else if (brgy == "San Jose") {
      total += 400;
    } else if (brgy == "Burgos") {
      total += 400;
    } else if (brgy == "Manggahan") {
      total += 400;
    } else if (brgy == "Rosario") {
      total += 350;
    } else if (brgy == "Balite") {
      total += 350;
    } else if (brgy == "Geronimo") {
      total += 350;
    } else if (brgy == "San Rafael") {
      total += 300;
    } else if (brgy == "Mascap") {
      total += 200;
    } else if (brgy == "Macabud") {
      total += 350;
    } else if (brgy == "Puray") {
      total += 250;
    } else {
      total += 0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        children: [
                          Text(
                            "Buyer Name:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.orderData.data()['Name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Contact No:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.orderData.data()['Contact'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address:",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: AutoSizeText(
                              widget.orderData.data()['Address'],
                              minFontSize: 0,
                              wrapWords: true,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Order Date: ${widget.orderData.data()['Date'].toDate().toString().split(" ")[0]}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "Completed Date: ${widget.orderData.data()['Date Completed']}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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
              Column(
                children: List.generate(widget.orderData.data()['Items'].length, (index){
                  return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('Items')
                          .doc(widget.orderData.data()['Items'][index].toString().split(",")[0])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                child: Image.network(
                                  snapshot.data!['Url'],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              snapshot.data!['Name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "PHP${snapshot.data!['Price']}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              "x${widget.orderData.data()['Items'][index].toString().split(",")[1]}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                  );
                }),
              ),
            /*  ListView.builder(
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
                        return ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              child: Image.network(
                                snapshot.data!['Url'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            snapshot.data!['Name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "₱${snapshot.data!['Price']}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                          trailing: Text(
                            "x${widget.orderData.data()['Items'][index].toString().split(",")[1]}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  );

                },
              ),*/
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
