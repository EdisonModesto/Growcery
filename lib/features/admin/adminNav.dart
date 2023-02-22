import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growcery/features/admin/1.%20Home/aHomeView.dart';
import 'package:growcery/features/admin/2.%20Orders/aOrderView.dart';
import 'package:growcery/features/admin/3.%20Profile/aProfileView.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../common/AuthRequiredDialog.dart';
import '../../constants/AppColors.dart';
import '../ViewModels/AuthViewModels.dart';

class AdminNav extends ConsumerStatefulWidget {
  const AdminNav({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AdminNavState();
}

class _AdminNavState extends ConsumerState<AdminNav> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);


  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: AppColors().primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.local_shipping_outlined),
        title: ("Orders"),
        activeColorPrimary: AppColors().primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.person),
        title: ("Profile"),
        activeColorPrimary: AppColors().primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }


  List<Widget> _buildScreens() {
    return [
      const AHomeView(),
      const AOrderView(),
      const AProfileView()
    ];
  }

  void onChangeState()async{
    await Future.delayed(Duration(seconds: 1));
    if(mounted){
      context.go("/user");
    }
  }


  @override
  Widget build(BuildContext context) {

    var authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data){
        if(data?.uid == null){
          onChangeState();
        }
        return PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.white, // Default is Colors.white.
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
          onItemSelected: (index) {

          },
        );
      },
      error: (error, stack){
        return Center(child: Text(error.toString()));
      },
      loading: (){
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
