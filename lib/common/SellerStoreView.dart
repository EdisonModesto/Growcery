import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Users").doc(widget.sellerID).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors().primaryColor,
                        backgroundImage: NetworkImage(snapshot.data!["Image"]),
                      ),
                      SizedBox(height: 15),
                      Text(
                        snapshot.data!["Name"],
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                                      return int.parse(sellerItems[index].data()["Stocks"]) > 0 ? InkWell(
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
                      )
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}
