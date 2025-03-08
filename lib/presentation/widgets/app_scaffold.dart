// lib/presentation/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../navigation/app_router.dart';

enum AppTab {
  home,
  help,
  profile,
}

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final AppTab currentTab;
  final bool showBottomNavigation;

  const AppScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    required this.currentTab,
    this.showBottomNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNavigation
          ? BottomNavigationBar(
        currentIndex: currentTab.index,
        onTap: (index) {
          final tab = AppTab.values[index];
          if (tab != currentTab) {
            _navigateToTab(context, tab);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Допомога',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      )
          : null,
    );
  }

  void _navigateToTab(BuildContext context, AppTab tab) {
    String route;
    switch (tab) {
      case AppTab.home:
        route = AppRouter.home;
        break;
      case AppTab.help:
        route = AppRouter.help;
        break;
      case AppTab.profile:
        route = AppRouter.profile;
        break;
    }

    Navigator.pushReplacementNamed(context, route);
  }
}