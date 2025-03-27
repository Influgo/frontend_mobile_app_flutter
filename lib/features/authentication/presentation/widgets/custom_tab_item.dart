import 'package:flutter/material.dart';

class CustomTabItem extends StatelessWidget {
  final String title;
  final int index;
  final TabController tabController;

  const CustomTabItem({
    Key? key,
    required this.title,
    required this.index,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: tabController.index == index
          ? ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFC20B0C),
                    Color(0xFF7E0F9D),
                    Color(0xFF2616C7)
                  ],
                ).createShader(bounds);
              },
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
    );
  }
}
