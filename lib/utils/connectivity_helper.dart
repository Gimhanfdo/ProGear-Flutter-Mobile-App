import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> showConnectivitySnackBar(BuildContext context) async {
  var result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You're currently offline. Check your internet connection"),
      ),
    );
  }
}
