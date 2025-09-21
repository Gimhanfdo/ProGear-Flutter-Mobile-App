import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/product.dart';
import 'package:progear_mobileapp/screens/product_details.dart';
import 'package:progear_mobileapp/screens/shared/custom_app_bar.dart';
import 'package:progear_mobileapp/screens/shared/product_card.dart';
import 'package:progear_mobileapp/services/product_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int isSelected = 0;

  List<String> productCategories = [
    "Cricket Bats",
    "Cricket Balls",
    "Cricket Helmets",
    "Other Equipment",
  ];

  List<String> databaseProductCategories = ["Bat", "Ball", "Helmet", "Other"];

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getProductsByCategory(
      databaseProductCategories[0],
    );
  }

  void _loadCategory(int index) {
    setState(() {
      isSelected = index;
      _productsFuture = ProductService.getProductsByCategory(
        databaseProductCategories[index],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productCategories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _loadCategory(index),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected == index
                                ? Colors.teal.shade700
                                : Colors.teal.shade300,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        productCategories[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Products Grid
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  final products = snapshot.data!;
                  final orientation = MediaQuery.of(context).orientation;
                  final crossAxisCount =
                      orientation == Orientation.landscape ? 3 : 2;
                  final childAspectRatio =
                      orientation == Orientation.landscape
                          ? (100 / 110)
                          : (100 / 140);

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        child: ProductCard(product: product),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductDetailsPage(
                                    productId: product.productID,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
