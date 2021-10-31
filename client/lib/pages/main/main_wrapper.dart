import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:client/pages/main/home_page.dart';
import 'package:client/pages/main/profile_page.dart';
import 'package:client/pages/main/todo_page.dart';
import 'package:client/pages/main/statistics_page.dart';
import 'package:client/pages/main/user_input_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  PageController pageController = PageController(initialPage: 1);

  final pages = [
    const ProfilePage(),
    const HomePage(),
    const StatisticsPage(),
    const ToDoPage(),
    const DataInput()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: pages,
      ),
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: 1,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.account_circle, title: 'Profile'),
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.bar_chart, title: 'Statistics'),
          TabItem(icon: Icons.shopping_cart, title: 'Shopping'),
        ],
        onTap: (index) => pageController.jumpToPage(index),
      ),
    );
  }
}
