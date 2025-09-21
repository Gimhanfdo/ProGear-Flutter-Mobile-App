import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final textController;
  final String hintText;
  final bool obscureText;
  final VoidCallback? onTap;

  //Constructor
  const CustomTextField({
    super.key,
    required this.labelText,
    required this.textController,
    required this.hintText,
    required this.obscureText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30), //External padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText), //Shows the label above the text field

          const SizedBox(height: 10),

          TextField(
            controller: textController,
            obscureText: obscureText, //for password fields
            readOnly: onTap != null, //Make the text box readonly if onTap is given
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder( //Border
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder( //Border when focused
                borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true, //Fills background
              hintText: hintText, //Placeholder text
              hintStyle: TextStyle(fontSize: 14),
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
