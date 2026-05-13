import 'package:flutter/material.dart';

import 'tour_list_screen.dart';
import 'search_screen.dart';
import 'my_trips_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {

  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      TourListScreen(),
      SearchScreen(),
      MyTripsScreen(),
      NotificationsScreen(),
      ProfileScreen(email: widget.email),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF00D1A3),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index){
            setState(() {
              if (index >= 0 && index < screens.length) {
                currentIndex = index;
              }
            });
          },

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home_filled, size: 24),
              label: "Trang chủ",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined, size: 24),
              activeIcon: Icon(Icons.search, size: 24),
              label: "Tìm kiếm",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.card_travel_outlined, size: 24),
              activeIcon: Icon(Icons.card_travel, size: 24),
              label: "Chuyến",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, size: 24),
              activeIcon: Icon(Icons.notifications, size: 24),
              label: "Thông báo",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: "Hồ sơ",
            ),

          ],
        ),
      ),
    );
  }
}
