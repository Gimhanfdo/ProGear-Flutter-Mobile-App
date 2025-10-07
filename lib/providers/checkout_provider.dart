import 'package:flutter/material.dart';
import 'package:progear_mobileapp/services/checkout_service.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutService _service = CheckoutService();

  Map<String, dynamic>? _checkoutData;
  bool _isLoading = false;
  String? _errorMessage;

  String shippingAddress = '';
  String paymentMethod = '';

  Map<String, dynamic>? get checkoutData => _checkoutData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load checkout data (cart + subtotal)
  Future<void> loadCheckout() async {
    try {
      _isLoading = true;
      notifyListeners();

      _checkoutData = await _service.fetchCheckoutData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place order
  Future<bool> placeOrder() async {
    if (shippingAddress.isEmpty || paymentMethod.isEmpty) {
      _errorMessage = "Shipping address and payment method are required.";
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _service.submitOrder({
        'shippingaddress': shippingAddress,
        'paymentmethod': paymentMethod,
      });

      // Clear checkout state after success
      _checkoutData = null;
      _errorMessage = null;
      shippingAddress = '';
      paymentMethod = '';

      return response['success'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
