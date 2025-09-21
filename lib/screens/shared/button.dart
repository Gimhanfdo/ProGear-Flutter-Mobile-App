import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final String? iconPath; //Optional to have an icon
  final VoidCallback?
  onTap; // Callback function triggered when the button is tapped

  //Constructor
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.buttonColor,
    this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize a variable to hold the icon widget if exists
    Widget? leadingIcon;

    if (iconPath != null) {
      leadingIcon = Image.asset(iconPath!, width: 24, height: 24);
    }

    return GestureDetector(
      onTap: onTap, //Call the ontap function when the button is clicked
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30), //External padding
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10), //Internal padding
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[ //Display the icon if given
                  leadingIcon,
                  const SizedBox(width: 12),
                ],
                Text( //Button text
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
