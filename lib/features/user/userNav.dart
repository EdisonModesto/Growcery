import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growcery/common/AuthRequiredDialog.dart';
import 'package:growcery/constants/AppColors.dart';
import 'package:growcery/features/ViewModels/AuthViewModels.dart';
import 'package:growcery/features/user/1.%20Home/uHomeView.dart';
import 'package:growcery/features/user/2.%20Basket/uBasketView.dart';
import 'package:growcery/features/user/3.%20Profile/uProfileView.dart';
import 'package:growcery/services/AuthService.dart';
import 'package:growcery/services/FirestoreService.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class UserNav extends ConsumerStatefulWidget {
  const UserNav({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UserNavState();
}

class _UserNavState extends ConsumerState<UserNav> {

  PersistentTabController _controller = PersistentTabController(initialIndex: 0);


  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: AppColors().primaryColor,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.shopping_basket_outlined),
        title: ("Basket"),
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
      const UHomeView(),
      const UBasketView(),
      const UProfileView()
    ];
  }

  Future<void> checkUser() async {
    if(await FirestoreService().checkUserExist(AuthService().getID()) == false){
      if(mounted){
        context.go("/admin");
      }
    }

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    var authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data){
        if(data?.uid != null){
          checkUser();
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
            if(index == 1){
              if(data?.uid == null){
                showDialog(context: context, builder: (builder){
                  return const AuthRequiredDialog();
                }).whenComplete((){
                  _controller.jumpToTab(2);
                });
              }
            }
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
