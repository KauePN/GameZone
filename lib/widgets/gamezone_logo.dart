import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GameZoneLogo extends StatelessWidget {
  final double size;
  const GameZoneLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
            borderRadius: BorderRadius.circular(size * .25),
          ),
          child: Icon(
            Icons.sports_esports_rounded,
            color: Colors.white,
            size: size * .55,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'GAMEZONE',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * .25,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
