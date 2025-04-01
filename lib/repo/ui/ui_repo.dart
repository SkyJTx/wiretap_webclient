import 'dart:async';
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

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    navigatorKey: navigatorKey,
    initialLocation: HomePage.path,
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

  BuildContext get context {
    if (navigatorKey.currentContext == null) {
      throw Exception('UiRepo not initialized');
    }
    return navigatorKey.currentContext!;
  }

  Future<dynamic> showConfirmDialog(
    BuildContext context,
    String message, {
    String? title,
    FutureOr<dynamic> Function()? onConfirm,
    FutureOr<dynamic> Function()? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title ?? 'Confirmation'),
            content: Text(message),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.error,
                  foregroundColor: context.theme.colorScheme.onError,
                ),
                onPressed: () => Navigator.of(context).pop(onCancel?.call()),
                child: Text(
                  'Cancel',
                  style: context.theme.textTheme.labelLarge?.copyWith(
                    color: context.theme.colorScheme.onError,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(onConfirm?.call()),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<T?> showErrorDialog<T>(
    BuildContext context,
    String message, {
    String? title,
    FutureOr<T> Function()? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title ?? 'Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(onConfirm?.call()),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CircularProgressIndicator(year2023: false),
          ),
        );
      },
    );
  }

  void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? foregroundColor,
    Icon? icon,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? context.theme.colorScheme.surfaceContainerLowest,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon != null) icon,
            Expanded(
              child: Text(
                message,
                style: context.theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor ?? context.theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
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
