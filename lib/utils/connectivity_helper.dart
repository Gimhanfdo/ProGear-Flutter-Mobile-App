// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

//Function to show a snack bar if offline
Future<void> showConnectivitySnackBar(BuildContext context) async {
  var result = await Connectivity().checkConnectivity();
  // ignore: unrelated_type_equality_checks
  if (result == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You're currently offline. Check your internet connection"),
      ),
    );
  }
}
