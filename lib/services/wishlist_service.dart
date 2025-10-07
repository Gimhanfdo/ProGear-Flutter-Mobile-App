import '../utils/database_helper.dart';
import '../models/product.dart';

class WishlistService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Function to add product to wishlist
  static Future<void> addItem(Product product) async {
    await _dbHelper.addToWishlist({
      'id': product.productID,
      'name': product.productName,
      'price': product.price,
      'image': product.productImage,
    });
  }

  // Function to get wishlist items for current user
  static Future<List<Product>> getWishlist() async {
    final items = await _dbHelper.getWishlist();
    return items.map((item) {
      return Product(
        productID: item['product_id'],
        productName: item['product_name'] ?? '',
        productBrand: '', 
        category: '', 
        price: item['product_price'] ?? 0.0,
        productImage: item['product_image'] ?? '',
        description: '', 
        discountPercentage: null,
        quantityAvailable: 0, 
      );
    }).toList();
  }

  // Function to remove a product from wishlist
  static Future<void> removeItem(int productId) async {
    await _dbHelper.removeFromWishlist(productId);
  }

  // Function to clear wishlist for current user
  static Future<void> clearWishlist() async {
    await _dbHelper.clearWishlist();
  }
}
