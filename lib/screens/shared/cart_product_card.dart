import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progear_mobileapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartProductCard extends StatelessWidget {
  final int productId;

  const CartProductCard({super.key, required this.productId});

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
        hasDiscount
            ? product.price * (1 - product.discountPercentage! / 100)
            : product.price;
    final double totalPrice = unitPrice * quantity;

    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: CachedNetworkImage(
          imageUrl: product.productImage,
          placeholder:
              (context, url) => const CircularProgressIndicator(strokeWidth: 2),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        ),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (quantity > 1) {
                    cartProvider.updateQuantity(productId, quantity - 1);
                  } else {
                    cartProvider.removeItem(productId);
                  }
                },
              ),
              Text('$quantity'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  try {
                    await cartProvider.updateQuantity(productId, quantity + 1);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This product has limited stock available',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () {
          cartProvider.removeItem(productId);
        },
      ),
    );
  }
}
