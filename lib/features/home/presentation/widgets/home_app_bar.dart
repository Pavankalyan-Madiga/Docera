import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    this.onSettingsTap,
  });

  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Do',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101631),
                    letterSpacing: -1.5,
                  ),
                ),
                TextSpan(
                  text: 'c',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2167E8),
                    letterSpacing: -1.5,
                  ),
                ),
                TextSpan(
                  text: 'era',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101631),
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Material(
            color: const Color(0xFFF0F2FA),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSettingsTap,
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(
                  Icons.settings_outlined,
                  size: 21,
                  color: Color(0xFF11182F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}