import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/presentation/authen/authen_cubit.dart';
import 'package:wiretap_webclient/presentation/authen/authen_page.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

class Wrapper extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const Wrapper({super.key, required this.child, required this.state});

  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final landscape = size.width > size.height;
    return ValueListenableBuilder(
      valueListenable: _selectedIndex,
      builder: (context, value, child) {
        return Scaffold(
          appBar:
              !landscape
                  ? AppBar(
                    title: const Text('WireTap'),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.theme.colorScheme.error,
                          foregroundColor: context.theme.colorScheme.onError,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          BlocProvider.of<AuthenCubit>(context).logout();
                        },
                        child: Text(
                          'Logout',
                          style: context.theme.textTheme.labelLarge?.copyWith(
                            color: context.theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ],
                  )
                  : null,
          body: SafeArea(
            child: AuthenPage(
              child: Builder(
                builder: (context) {
                  if (landscape) {
                    return Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: context.theme.colorScheme.shadow,
                                blurRadius: 16,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: NavigationRail(
                            backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
                            selectedLabelTextStyle: context.theme.textTheme.labelLarge?.copyWith(
                              color: context.theme.colorScheme.primary,
                            ),
                            unselectedLabelTextStyle: context.theme.textTheme.labelLarge?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                            selectedIconTheme: context.theme.iconTheme.copyWith(
                              color: context.theme.colorScheme.primary,
                            ),
                            unselectedIconTheme: context.theme.iconTheme.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                            labelType:
                                size.width > 1280
                                    ? NavigationRailLabelType.all
                                    : NavigationRailLabelType.selected,
                            leading: Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                                top: 8,
                                right: 8,
                                bottom: context.h(0.15),
                              ),
                              child: Text(
                                'WireTap',
                                style: context.theme.textTheme.titleMedium?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            destinations:
                                UiRepo.routeValues.map((route) {
                                  return NavigationRailDestination(
                                    icon: Icon(route.icon),
                                    label: Text(route.label),
                                  );
                                }).toList(),
                            selectedIndex: value,
                            onDestinationSelected: (index) {
                              _selectedIndex.value = index;
                              context.go(UiRepo.routeValues[index].path);
                            },
                          ),
                        ),
                        Expanded(child: widget.child),
                      ],
                    );
                  }
                  return widget.child;
                },
              ),
            ),
          ),
          bottomNavigationBar:
              landscape
                  ? null
                  : BottomNavigationBar(
                    items:
                        UiRepo.routeValues.map((route) {
                          return BottomNavigationBarItem(
                            icon: Icon(route.icon),
                            label: route.label,
                          );
                        }).toList(),
                    currentIndex: value,
                    onTap: (index) {
                      _selectedIndex.value = index;
                      context.go(UiRepo.routeValues[index].path);
                    },
                  ),
        );
      },
    );
  }
}
