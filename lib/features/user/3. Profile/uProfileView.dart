import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";
import "package:growcery/common/AuthDialog.dart";
import "package:growcery/constants/AppColors.dart";

import '../../../common/ViewItemSheet.dart';
import "../../ViewModels/AuthViewModels.dart";

class UProfileView extends ConsumerStatefulWidget {
  const UProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UOrderViewState();
}

class _UOrderViewState extends ConsumerState<UProfileView> {
  @override
  Widget build(BuildContext context) {

    var authState = ref.watch(authStateProvider);

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
                    "Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      data?.uid == null ? const CircleAvatar(
                        radius: 35,
                        child: Icon(Icons.person),
                      ) :
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                      ),
                      const SizedBox(width: 20,),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data?.uid == null ? "Login to continue" : "John Doe",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                              ),
                            ),
                            Visibility(
                              visible: data?.uid == null ? true : false,
                              child: ElevatedButton(
                                onPressed: (){
                                  showDialog(context: context, builder: (builder){
                                    return AuthDialog();
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
                                  "Login or Signup",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            )
                          ]
                      )
                    ],
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

                    TabBarView(
                      children: [
                        ListView.separated(
                          itemCount: 4,
                          itemBuilder: (context, index){
                            return InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => const ViewItemSheet(),
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
                                      decoration: BoxDecoration(
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
                                            "Product Name",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Quantity: 1",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: 100",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
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
                          itemCount: 3,
                          itemBuilder: (context, index){
                            return InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => const ViewItemSheet(),
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
                                      decoration: BoxDecoration(
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
                                            "Product Name",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Quantity: 1",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: 100",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
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
                          itemCount: 1,
                          itemBuilder: (context, index){
                            return InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => const ViewItemSheet(),
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
                                      decoration: BoxDecoration(
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
                                            "Product Name",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Quantity: 1",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: 100",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
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
                        InkWell(
                          onTap: (){
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const ViewItemSheet(),
                            );
                          },
                          child: ListView.separated(
                            itemCount: 5,
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
                                      decoration: BoxDecoration(
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
                                            "Product Name",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Quantity: 1",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: 100",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
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
                        ),


                      ],
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
