import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/AppColors.dart';
import '../features/ViewModels/ItemViewModel.dart';
import '../features/ViewModels/allUserViewModel.dart';
import 'ViewItemSheet.dart';

class SellerStartView extends ConsumerStatefulWidget {
  const SellerStartView({
    required this.sellerID,
    Key? key,
  }) : super(key: key);

  final sellerID;

  @override
  ConsumerState createState() => _SellerStartViewState();
}

class _SellerStartViewState extends ConsumerState<SellerStartView> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var feed = ref.watch(itemProvider);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Users").doc(widget.sellerID).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 12,
                      child: Container(
                        width: double.infinity,
                        color: AppColors().primaryColor,
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors().primaryColor,
                              backgroundImage: NetworkImage(snapshot.data!["Image"]),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              snapshot.data!["Name"],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!["Address"].toString().replaceAll("%", ", "),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("Users").doc(widget.sellerID).collection("Ratings").snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    double totalRating = 0;

                                    snapshot.data!.docs.forEach((element) {
                                      totalRating += element.data()["Rating"];
                                    });

                                    totalRating = totalRating == 0 ? 0.0 : totalRating / snapshot.data!.docs.length;
                                    return RatingBar.builder(
                                      initialRating: totalRating,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal:0),
                                      itemSize: 30,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    );
                                  }
                                  return const SizedBox();
                                }
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: Container(
                        padding: EdgeInsets.only(left: 30, right: 30),

                        color: Colors.white,
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            TabBar(
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: AppColors().primaryColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorWeight: 2,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors().primaryColor,
                              ),
                              isScrollable: true,
                              tabs: [
                                Tab(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      "Product",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      "Categories",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  feed.when(
                                    data: (data){
                                      var sellerItems = data.docs.where((element) => element.data()["SellerID"] == widget.sellerID).toList();
                                      return GridView.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          childAspectRatio: 0.8,
                                          children: List.generate(sellerItems.length, (index){
                                            return int.parse(sellerItems[index].data()["Stocks"]) > 0 ? Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: InkWell(
                                                onTap: (){
                                                  showModalBottomSheet(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.vertical(
                                                        top: Radius.circular(12),
                                                      ),
                                                    ),
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) => ViewItemSheet(
                                                      name: sellerItems[index].data()['Name'],
                                                      price: sellerItems[index].data()['Price'],
                                                      description: sellerItems[index].data()['Description'],
                                                      stock:sellerItems[index].data()['Stocks'],
                                                      image: sellerItems[index].data()['Url'],
                                                      id: sellerItems[index].id,
                                                      min: sellerItems[index].data()['Minimum'],
                                                      sellerID: sellerItems[index].data()['SellerID'],
                                                      measurement: sellerItems[index].data()['Measurement'],


                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Image.network(
                                                            sellerItems[index].data()['Url'],
                                                            width: double.infinity,
                                                            fit: BoxFit.fitWidth,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            color: AppColors().primaryColor,
                                                            width: double.infinity,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    sellerItems[index].data()['Name'],
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: GoogleFonts.poppins(
                                                                      color: Colors.white,
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 5),
                                                                  Text(
                                                                    "PHP ${sellerItems[index].data()['Price']}/KG",
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: GoogleFonts.poppins(
                                                                      color: Colors.white,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ) : ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    color: Colors.grey[200],
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Image.network(
                                                            sellerItems[index].data()['Url'],
                                                            width: double.infinity,
                                                            fit: BoxFit.fitWidth,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(20.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  sellerItems[index].data()['Name'],
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                Text(
                                                                  "PHP ${sellerItems[index].data()['Price']}/KG",
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height,
                                                    color: Colors.grey.withOpacity(0.8),
                                                    child: Center(
                                                      child: Text(
                                                        "Out of Stock",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                      );
                                    },
                                    error: (error, stack){
                                      return Center(
                                        child: Text(
                                          error.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                    loading: (){
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                  feed.when(
                                    data: (data){

                                      var vegies = data.docs.where((element) => element.data()['Category'] == "Vegetables" && element.data()["SellerID"] == widget.sellerID).toList();
                                      var frutis = data.docs.where((element) => element.data()['Category'] == "Fruits" && element.data()["SellerID"] == widget.sellerID).toList();
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            ExpansionTile(
                                                title: Text(
                                                  "Vegetables (${vegies.length})",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                children: List.generate(vegies.length, (index) => ListTile(
                                                  onTap: (){
                                                    showModalBottomSheet(
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(12),
                                                        ),
                                                      ),
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) => ViewItemSheet(
                                                        name: vegies[index].data()['Name'],
                                                        price: vegies[index].data()['Price'],
                                                        description: vegies[index].data()['Description'],
                                                        stock:vegies[index].data()['Stocks'],
                                                        image: vegies[index].data()['Url'],
                                                        id: vegies[index].id,
                                                        min: vegies[index].data()['Minimum'],
                                                        sellerID: vegies[index].data()['SellerID'],
                                                        measurement: vegies[index].data()['Measurement'],
                                                      ),
                                                    );
                                                  },
                                                  leading: Image.network(
                                                    vegies[index].data()['Url'],
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  title: Text(
                                                    vegies[index].data()['Name'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "Stocks: ${vegies[index].data()['Stocks'].toString()}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),

                                                  trailing: Text(
                                                    "PHP ${vegies[index].data()['Price']}/KG",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ))
                                            ),
                                            ExpansionTile(
                                                title: Text(
                                                  "Fruits (${frutis.length})",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                children: List.generate(frutis.length, (index) => ListTile(
                                                  onTap: (){
                                                    showModalBottomSheet(
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(12),
                                                        ),
                                                      ),
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) => ViewItemSheet(
                                                        name: frutis[index].data()['Name'],
                                                        price: frutis[index].data()['Price'],
                                                        description: frutis[index].data()['Description'],
                                                        stock:frutis[index].data()['Stocks'],
                                                        image: frutis[index].data()['Url'],
                                                        id: frutis[index].id,
                                                        min: frutis[index].data()['Minimum'],
                                                        sellerID: frutis[index].data()['SellerID'],
                                                        measurement: frutis[index].data()['Measurement'],
                                                      ),
                                                    );
                                                  },
                                                  leading: Image.network(
                                                    frutis[index].data()['Url'],
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  title: Text(
                                                    frutis[index].data()['Name'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "Stocks: ${frutis[index].data()['Stocks'].toString()}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),

                                                  trailing: Text(
                                                    "PHP ${frutis[index].data()['Price']}/KG",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ))

                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    error: (error, stack){
                                      return Center(
                                        child: Text(
                                          error.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                    loading: (){
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          ),
        ),
      ),
    );
  }
}
