import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:growcery/common/AuthView.dart';
import 'package:growcery/common/SellerStoreView.dart';
import 'package:growcery/features/seller/sellerNav.dart';
import 'package:growcery/features/splashView.dart';
import 'package:growcery/features/user/userNav.dart';

class AppRoutes{
  var routes = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashView(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => UserNav(),
      ),
      GoRoute(
        path: '/seller',
        builder: (context, state) => SellerNav(),
      ),
      GoRoute(
        path: '/sellerStore:sellerID',
        name: "sellerStore",
        builder: (context, state) => SellerStartView(sellerID: state.params['sellerID']!),
      ),
      GoRoute(
        path: "/auth",
        builder: (context, state) => AuthView(),
      )
    ],
  );
}

//facebook.com/profileID