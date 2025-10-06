import '../utils/database_helper.dart';
import '../models/product.dart';

class WishlistService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Add product to wishlist
  static Future<void> addItem(Product product) async {
    await _dbHelper.addToWishlist({
      'id': product.productID,
      'name': product.productName,
      'price': product.price,
      'image': product.productImage,
    });
  }

  // Get wishlist items for current user
  static Future<List<Product>> getWishlist() async {
    final items = await _dbHelper.getWishlist();
    return items.map((item) {
      return Product(
        productID: item['product_id'],
        productName: item['product_name'] ?? '',
        productBrand: '', // not stored locally
        category: '', // not stored locally
        price: item['product_price'] ?? 0.0,
        productImage: item['product_image'] ?? '',
        description: '', // not stored locally
        discountPercentage: null,
        quantityAvailable: 0, // not stored locally
      );
    }).toList();
  }

  // Remove a product from wishlist
  static Future<void> removeItem(int productId) async {
    await _dbHelper.removeFromWishlist(productId);
  }

  // Clear wishlist for current user
  static Future<void> clearWishlist() async {
    await _dbHelper.clearWishlist();
  }
}
