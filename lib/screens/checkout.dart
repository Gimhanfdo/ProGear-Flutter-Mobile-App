import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../screens/shared/checkout_product_card.dart';
import '../screens/shared/text_field.dart';
import '../screens/shared/error_alert_dialog.dart';
import '../services/biometric_service.dart';
import 'navigation_wrapper.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final shippingAddressController = TextEditingController();
  final creditCardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();

  String paymentMethod = 'COD';
  String cardType = 'Mastercard';

  /// Validate card details if payment = Card
  bool _validateCardDetails(BuildContext context) {
    final number = creditCardNumberController.text.trim();
    final expiry = expiryDateController.text.trim();
    final cvv = cvvController.text.trim();

    if (number.isEmpty || expiry.isEmpty || cvv.isEmpty) {
      showErrorAlertDialog(context, 'Please complete all card details.');
      return false;
    }
    if (!RegExp(r'^\d{16}$').hasMatch(number)) {
      showErrorAlertDialog(context, 'Card number must be 16 digits.');
      return false;
    }
    if (!RegExp(r'^\d{3}$').hasMatch(cvv)) {
      showErrorAlertDialog(context, 'CVV must be 3 digits.');
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permissions permanently denied"),
          ),
        );
        return;
      }

      // Get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String fullAddress =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          shippingAddressController.text = fullAddress;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to get location: $e")));
    }
  }

  /// Place order through CheckoutProvider
  Future<void> _placeOrder(BuildContext context) async {
    final checkoutProvider = Provider.of<CheckoutProvider>(
      context,
      listen: false,
    );

    final shippingAddress = shippingAddressController.text.trim();
    if (shippingAddress.isEmpty) {
      showErrorAlertDialog(context, 'Please enter a shipping address.');
      return;
    }

    if (paymentMethod == 'Card' && !_validateCardDetails(context)) return;

    try {
      checkoutProvider.shippingAddress = shippingAddress;
      checkoutProvider.paymentMethod = paymentMethod;
      final success = await checkoutProvider.placeOrder(
        // shippingAddress: shippingAddress,
        // paymentMethod: paymentMethod,
        // cardType: paymentMethod == 'Card' ? cardType : null,
        // cardNumber: paymentMethod == 'Card' ? creditCardNumberController.text : null,
        // expiryDate: paymentMethod == 'Card' ? expiryDateController.text : null,
        // cvv: paymentMethod == 'Card' ? cvvController.text : null,
        // totalAmount: cartProvider.total,
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text("PROGEAR"),
                content: const Text("Order placed successfully!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NavigationWrapper(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      showErrorAlertDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final theme = Theme.of(context);

    Widget sectionTitle(String title) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Divider(color: theme.colorScheme.inversePrimary),
        const SizedBox(height: 8),
      ],
    );

    return Consumer2<CartProvider, CheckoutProvider>(
      builder: (context, cartProvider, checkoutProvider, _) {
        final cartItems = cartProvider.items.values.toList();

        Widget checkoutForm = Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Delivery Details"),
              CustomTextField(
                labelText: "Shipping Address",
                textController: shippingAddressController,
                hintText: "Enter your shipping address",
                obscureText: false,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Use Current Location"),
                ),
              ),
              const SizedBox(height: 16),
              sectionTitle("Payment Information"),
              Row(
                children: [
                  Radio(
                    value: 'COD',
                    groupValue: paymentMethod,
                    onChanged:
                        (val) => setState(() => paymentMethod = val.toString()),
                  ),
                  const Text("Cash on Delivery"),
                  Radio(
                    value: 'Card',
                    groupValue: paymentMethod,
                    onChanged:
                        (val) => setState(() => paymentMethod = val.toString()),
                  ),
                  const Text("Card Payment"),
                ],
              ),
              if (paymentMethod == 'Card') ...[
                Row(
                  children: [
                    Radio(
                      value: 'Mastercard',
                      groupValue: cardType,
                      onChanged:
                          (val) => setState(() => cardType = val.toString()),
                    ),
                    Image.asset(
                      'assets/images/icons8-mastercard-48.png',
                      width: 40,
                      height: 40,
                    ),
                    Radio(
                      value: 'Visa',
                      groupValue: cardType,
                      onChanged:
                          (val) => setState(() => cardType = val.toString()),
                    ),
                    Image.asset(
                      'assets/images/icons8-visa-48.png',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
                CustomTextField(
                  labelText: "Card Number",
                  textController: creditCardNumberController,
                  hintText: "XXXX-XXXX-XXXX-XXXX",
                  obscureText: false,
                ),
                CustomTextField(
                  labelText: "Expiry Date",
                  textController: expiryDateController,
                  hintText: "MM/YY",
                  obscureText: false,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (picked != null) {
                      expiryDateController.text = DateFormat(
                        "MM/yy",
                      ).format(picked);
                    }
                  },
                ),
                CustomTextField(
                  labelText: "CVV",
                  textController: cvvController,
                  obscureText: true,
                  hintText: '',
                ),
              ],
            ],
          ),
        );

        Widget orderSummary = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Order Summary"),
            ...cartItems
                .map(
                  (item) =>
                      CheckoutProductCard(productId: item.product.productID),
                )
                .toList(),
            Divider(color: theme.colorScheme.inversePrimary),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _summaryRow("Sub Total", cartProvider.subTotal),
                  _summaryRow("VAT (18%)", cartProvider.vatValue),
                  _summaryRow("Total", cartProvider.total, highlight: true),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        checkoutProvider.isLoading
                            ? null
                            : () async {
                              final biometricService = BiometricService();

                              // Step 1: Authenticate user
                              final isAuthenticated =
                                  await biometricService.authenticateUser();

                              if (!isAuthenticated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Authentication failed or cancelled.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              // Step 2: If successful, place the order
                              await _placeOrder(context);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child:
                        checkoutProvider.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Confirm and Place Order",
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ],
              ),
            ),
          ],
        );

        return Scaffold(
          appBar: AppBar(title: const Text("Review Order")),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child:
                isLandscape
                    ? Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(child: checkoutForm),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SingleChildScrollView(child: orderSummary),
                        ),
                      ],
                    )
                    : ListView(
                      children: [
                        checkoutForm,
                        const SizedBox(height: 12),
                        orderSummary,
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, double amount, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Colors.teal[700] : null,
          ),
        ),
        Text(
          "LKR ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Colors.teal[700] : null,
          ),
        ),
      ],
    );
  }
}
