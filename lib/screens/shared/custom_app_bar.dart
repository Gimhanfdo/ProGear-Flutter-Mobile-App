import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 1, //Shadow
      title: Text(
        'PROGEAR',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [ //Static notifications icon 
        IconButton(onPressed: () {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        }, icon: Icon(Icons.person))
      ],
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}