class Product {
  int productID;
  String productName;
  String productBrand;
  String category;
  double price;
  String productImage;
  String description;
  double? discountPercentage;
  int quantityAvailable;

  Product({
    required this.productID,
    required this.productName,
    required this.productBrand,
    required this.category,
    required this.price,
    required this.productImage,
    required this.description,
    this.discountPercentage,
    required this.quantityAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productID: int.parse(json['id'].toString()),
      productName: json['name']?.toString() ?? '',
      productBrand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      productImage: json['productimage']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountPercentage:
          json['discountpercentage'] != null
              ? double.tryParse(json['discountpercentage'].toString()) ?? 0.0
              : null,
      quantityAvailable:
          int.tryParse(json['quantityavailable'].toString()) ?? 0,
    );
  }
}
