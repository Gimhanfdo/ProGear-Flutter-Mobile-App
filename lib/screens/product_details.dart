// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/product.dart';
import 'package:progear_mobileapp/providers/cart_provider.dart';
import 'package:progear_mobileapp/screens/shared/product_card.dart';
import 'package:progear_mobileapp/services/product_service.dart';
import 'package:progear_mobileapp/services/wishlist_service.dart';
import 'package:progear_mobileapp/screens/add_review_page.dart';
import 'package:progear_mobileapp/screens/shared/reviews_section.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Product> _productFuture;
  late Future<List<Product>> _relatedProductsFuture;
  int quantityCount = 0;
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService.getProductById(widget.productId);
    _checkIfInWishlist();
  }

  void decreaseQuantity() {
    setState(() {
      if (quantityCount > 0) quantityCount--;
    });
  }

  void increaseQuantity(int maxQty) {
    setState(() {
      if (quantityCount < maxQty) quantityCount++;
    });
  }

  Future<void> _checkIfInWishlist() async {
    final wishlist = await WishlistService.getWishlist();
    setState(() {
      isInWishlist = wishlist.any((p) => p.productID == widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Product Details"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReviewPage(productId: widget.productId),
            ),
          );
          if (result == true) {
            setState(() {}); // Refresh reviews after returning
          }
        },
        child: const Icon(Icons.rate_review),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No product found"));
          }

          final product = snapshot.data!;

          final bool isOutOfStock = product.quantityAvailable == 0;
          final bool isLimitedStock =
              product.quantityAvailable <= 5 && product.quantityAvailable > 0;
          final bool isDiscounted = (product.discountPercentage ?? 0) > 0;
          final discountedPrice =
              isDiscounted
                  ? product.price * (1 - product.discountPercentage! / 100)
                  : product.price;

          // Fetch related products once product is loaded
          _relatedProductsFuture = ProductService.getProductsByCategory(
            product.category,
          );

          Widget productImage = Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: CachedNetworkImage(
              imageUrl: product.productImage,
              fit: BoxFit.contain,
            ),
          );

          Widget productInfo = Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Brand: ${product.productBrand} | Category: ${product.category}",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Stock status
                if (isOutOfStock)
                  Text(
                    "Out of Stock",
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                else if (isLimitedStock)
                  Text(
                    "Limited Stock Available",
                    style: TextStyle(color: Colors.orange.shade700),
                  )
                else
                  Text(
                    "In Stock",
                    style: TextStyle(color: Colors.green.shade700),
                  ),

                const SizedBox(height: 12),

                // Price + discount
                if (isDiscounted) ...[
                  Text(
                    "Rs. ${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withAlpha(
                        153,
                      ), // 60% opacity
                    ),
                  ),
                  Text(
                    "Rs. ${discountedPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else
                  Text(
                    "Rs. ${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                const SizedBox(height: 16),

                // Quantity selector
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: decreaseQuantity,
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          "$quantityCount",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed:
                            () => increaseQuantity(product.quantityAvailable),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Add to cart
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed:
                            isOutOfStock ||
                                    quantityCount == 0 ||
                                    cartProvider.isInCart(product.productID)
                                ? null
                                : () async {
                                  try {
                                    // Call addItem with productId and quantity
                                    await cartProvider.addItem(
                                      product.productID,
                                      quantityCount,
                                    );

                                    // Show confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Product added to cart!'),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to add to cart: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixedVariant,
                        ),
                        child: Text(
                          cartProvider.isInCart(product.productID)
                              ? 'Already in Cart'
                              : 'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () async {
                          try {
                            if (isInWishlist) {
                              await WishlistService.removeItem(product.productID);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from wishlist'),
                                ),
                              );
                            } else {
                              await WishlistService.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to wishlist'),
                                ),
                              );
                            }
                      
                            setState(() {
                              isInWishlist = !isInWishlist;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating wishlist: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          Widget productDescription = Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Divider(color: theme.colorScheme.inversePrimary, thickness: 1),
              ],
            ),
          );

          // Layout difference for portrait vs landscape
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                orientation == Orientation.landscape
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: productImage,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(flex: 3, child: productInfo),
                          ],
                        ),
                        const SizedBox(height: 20),
                        productDescription,
                        const SizedBox(height: 20),
                        ReviewsSection(productId: product.productID),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Related Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRelatedProducts(),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: productImage),
                        const SizedBox(height: 10),
                        productInfo,
                        const SizedBox(height: 20),
                        productDescription,
                        const SizedBox(height: 20),
                        ReviewsSection(productId: product.productID),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Related Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRelatedProducts(),
                      ],
                    ),
          );
        },
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return FutureBuilder<List<Product>>(
      future: _relatedProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No related products found");
        }

        final products = snapshot.data!.take(6).toList();
        final screenOrientation = MediaQuery.of(context).orientation;
        final crossAxisCount =
            screenOrientation == Orientation.landscape ? 3 : 2;
        final childAspectRatio =
            screenOrientation == Orientation.landscape
                ? (100 / 110)
                : (100 / 140);
        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          scrollDirection: Axis.vertical,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final related = products[index];
            return InkWell(
              splashColor: Colors.tealAccent.withAlpha((0.3 * 255).round()),
              highlightColor: Colors.transparent,
              child: ProductCard(product: related),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ProductDetailsPage(productId: related.productID),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
