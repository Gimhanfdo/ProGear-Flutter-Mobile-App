import 'package:flutter/material.dart';
import 'package:progear_mobileapp/models/product.dart';
import 'package:progear_mobileapp/screens/product_details.dart';
import 'package:progear_mobileapp/screens/shared/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progear_mobileapp/screens/shared/product_card.dart';
import 'package:progear_mobileapp/screens/wishlist.dart';
import 'package:progear_mobileapp/services/product_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Product>> discountedProducts = Future.value([]);

  @override
  void initState() {
    super.initState();
    discountedProducts = ProductService.getDiscountedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CachedNetworkImage(
                  //For image optimization
                  imageUrl:
                      'https://cms-static.asics.com/media-libraries/109692/file.jpg?1729645527521?20241023213849',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: 20),

              SearchAnchor.bar(
                barHintText: 'What are you looking for?',

                suggestionsBuilder: (context, controller) {
                  return const [];
                },
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Greatness is Contagious.",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WishlistPage(),
                              ),
                            );
                          },
                          child: Text("View My Wishlist"),
                        ),
                      ],
                    ),
                    Image.asset('assets/images/cricket.png', height: 100),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Discounted Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  Image.asset(
                    'assets/icons/icons8-flash.png',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FutureBuilder for API call
              FutureBuilder<List<Product>>(
                future: discountedProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No discounted products found."),
                    );
                  }

                  final products = snapshot.data!;
                  final screenOrientation = MediaQuery.of(context).orientation;
                  final crossAxisCount =
                      screenOrientation == Orientation.landscape ? 3 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          screenOrientation == Orientation.landscape
                              ? (100 / 110)
                              : (100 / 140),
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: ProductCard(product: products[index]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductDetailsPage(
                                    productId: products[index].productID,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
