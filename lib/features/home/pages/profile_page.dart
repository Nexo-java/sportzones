import 'package:flutter/material.dart';

import '../../../shared/widgets/custom_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09092D),
      child: const Column(
        children: [
          CustomHeader(),
          Expanded(
            child: Center(
              child: Text(
                'Profile Page',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
