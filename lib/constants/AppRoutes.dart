import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:growcery/common/AuthView.dart';
import 'package:growcery/features/admin/adminNav.dart';
import 'package:growcery/features/user/userNav.dart';

class AppRoutes{
  var routes = GoRouter(
    initialLocation: '/user',
    routes: [
      GoRoute(
        path: '/user',
        builder: (context, state) => UserNav(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminNav(),
      ),
      GoRoute(
        path: "/auth",
        builder: (context, state) => AuthView(),
      )
    ],
  );
}

//facebook.com/profileID