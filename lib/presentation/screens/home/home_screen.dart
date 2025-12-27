import 'package:flutter/material.dart';
import 'widgets/island_canvas.dart';
import 'widgets/top_bar.dart';
import 'widgets/bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF87CEEB),
                        const Color(0xFFE0F2F7),
                      ],
                    ),
                  ),
                  child: const IslandCanvas(),
                ),
              ],
            ),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }
}
