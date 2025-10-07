import 'package:flutter/material.dart';
import 'package:progear_mobileapp/providers/cart_provider.dart';
import 'package:progear_mobileapp/screens/checkout.dart';
import 'package:progear_mobileapp/screens/shared/cart_product_card.dart';
import 'package:progear_mobileapp/screens/shared/custom_app_bar.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true; // To show a loading indicator while fetching cart data

  @override
  void initState() {
    super.initState();
    _fetchCart(); // Fetch cart data when the page loads
  }

  void _fetchCart() async { 
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.fetchCart(); // Fetch the user's cart from the CartProvider
    } catch (e) {
      debugPrint('Failed to fetch cart: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;

    // Use Consumer to rebuild UI automatically when the cart provider updates
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final cartItems = cart.items;

        // Show loading spinner while fetching data
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: screenOrientation == Orientation.landscape //Shows the CustomAppBar only in portrait
              ? null
              : const CustomAppBar(),
          body: cartItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your cart is empty', //Shows a cart is empty message when cartItems is empty
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                )
              : Column( //If cartItems is not empty
                  children: [
                    Expanded(
                      child: ListView(
                        children: cartItems.keys
                            .map((productId) => CartProductCard(
                                  productId: productId,
                                ))
                            .toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sub Total',
                                  style: TextStyle(fontSize: 18)),
                              Text(
                                'LKR ${cart.subTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('VAT (18%)',
                                  style: TextStyle(fontSize: 18)),
                              Text(
                                'LKR ${cart.vatValue.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                              ),
                              Text(
                                'LKR ${cart.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                            ),
                            child: const Text(
                              'Proceed to Checkout', // Navigate to CheckoutPage
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
