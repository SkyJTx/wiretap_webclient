import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wiretap_webclient/presentation/account/account_page.dart';
import 'package:wiretap_webclient/presentation/home/home_page.dart';
import 'package:wiretap_webclient/presentation/sessions/sessions_page.dart';
import 'package:wiretap_webclient/presentation/setting/setting_page.dart';
import 'package:wiretap_webclient/presentation/wrapper.dart';

class RouteNavigatorBuilder {
  final IconData icon;
  final String label;
  final String path;
  final String name;
  final List<RouteBase> routes;
  final Widget Function(BuildContext context) builder;

  const RouteNavigatorBuilder({
    required this.icon,
    required this.label,
    required this.path,
    required this.name,
    this.routes = const [],
    required this.builder,
  });
}

class UiRepo {
  UiRepo.createInstance();

  static UiRepo? _instance;

  factory UiRepo() {
    _instance ??= UiRepo.createInstance();
    return _instance!;
  }

  double? _width;
  double? _height;

  double get width {
    if (_width == null) {
      throw Exception('UiRepo not initialized');
    }
    return _width!;
  }

  double get height {
    if (_height == null) {
      throw Exception('UiRepo not initialized');
    }
    return _height!;
  }

  static final routeValues = [
    RouteNavigatorBuilder(
      path: HomePage.path,
      name: HomePage.name,
      icon: HomePage.icon,
      label: HomePage.label,
      builder: (context) => const HomePage(),
    ),
    RouteNavigatorBuilder(
      path: SessionsPage.path,
      name: SessionsPage.name,
      icon: SessionsPage.icon,
      label: SessionsPage.label,
      builder: (context) => const SessionsPage(),
    ),
    RouteNavigatorBuilder(
      path: AccountPage.path,
      name: AccountPage.name,
      icon: AccountPage.icon,
      label: AccountPage.label,
      builder: (context) => const AccountPage(),
    ),
    RouteNavigatorBuilder(
      path: SettingPage.path,
      name: SettingPage.name,
      icon: SettingPage.icon,
      label: SettingPage.label,
      builder: (context) => const SettingPage(),
    ),
  ];

  final GoRouter router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Wrapper(state: state, child: child);
        },
        routes: [
          for (final routeBuilder in routeValues)
            GoRoute(
              path: routeBuilder.path,
              name: routeBuilder.name,
              builder: (context, state) {
                return routeBuilder.builder(context);
              },
              routes: routeBuilder.routes,
            ),
        ],
      ),
    ],
  );
}

extension UiRepoContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  Size get size => MediaQuery.of(this).size;

  double w([double? mult]) {
    if (mult == null) {
      return size.width;
    } else {
      return size.width * mult;
    }
  }

  double h([double? mult]) {
    if (mult == null) {
      return size.height;
    } else {
      return size.height * mult;
    }
  }

  double get wp => size.width / 100;
  double get hp => size.height / 100;
  double get sp => math.sqrt(size.width * size.height) / 100;
  double get min => math.min(size.width, size.height);
  double get max => math.max(size.width, size.height);
}
