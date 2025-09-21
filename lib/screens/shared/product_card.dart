import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  bool hasDiscount(Product product) {
    return product.discountPercentage != 0;
  }

  double calculateDiscountedPrice(Product product) {
    return product.price * (1 - product.discountPercentage! / 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDiscounted = hasDiscount(product);
    final double? discountedPrice =
        isDiscounted ? calculateDiscountedPrice(product) : null;

    return Container(
      width: MediaQuery.of(context).size.width / 2, //Takes half of the screen width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.all(8.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Product Image
          SizedBox(
            height: 150,
            width: 150,
            child: CachedNetworkImage(
              //For image optimization
              imageUrl: product.productImage,
              fit: BoxFit.cover,
              placeholder: //Loading spinner
                  (context, url) =>
                      const Center(child: CircularProgressIndicator()),
              errorWidget: //Error image
                  (context, url, error) => const Icon(Icons.broken_image),
            ),
          ),

          const SizedBox(height: 10),
          //Product Name
          Text(
            product.productName,
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, //Adds ... to the end of the product name if necessary
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          //Product Price(s) will be displayed accordingly based on their discount
          if (isDiscounted) ...[
            //Discounted price
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(153), // 60% opacity
                decoration: TextDecoration.lineThrough,
              ),
            ),

            Text(
              'Rs. ${discountedPrice!.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
