import 'package:flutter/material.dart';
import 'package:progear_mobileapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CheckoutProductCard extends StatelessWidget {
  final int productId;

  const CheckoutProductCard({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItem = cartProvider.items[productId];

    if (cartItem == null) return const SizedBox();

    final product = cartItem.product;
    final quantity = cartItem.quantity;

    // Handle discounts
    final bool hasDiscount =
        product.discountPercentage != null && product.discountPercentage! > 0;
    final double unitPrice =
        hasDiscount ? product.price * (1 - product.discountPercentage! / 100) : product.price;
    final double totalPrice = unitPrice * quantity;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(product.productImage),
        ),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LKR ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Unit Price: LKR ${unitPrice.toStringAsFixed(2)}'),
            Text('Quantity: $quantity'),
          ],
        ),
      ),
    );
  }
}
