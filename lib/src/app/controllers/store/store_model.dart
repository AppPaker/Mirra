import 'package:flutter/foundation.dart'; // for ChangeNotifier
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShardModel with ChangeNotifier {
  int shards;

  ShardModel({required this.shards});

  void addShards(int amount) {
    shards += amount;
    _saveShardsToPrefs();
  }

  void useShards(int amount) {
    if (shards >= amount) {
      shards -= amount;
      _saveShardsToPrefs();
    } else {
      if (kDebugMode) {
        print("Not enough shards");
      }
    }
  }

  Future<void> _saveShardsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('userShards', shards);
  }

  Future<void> loadShardsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    shards = prefs.getInt('userShards') ?? 0;
  }
}

class ShardStoreModel with ChangeNotifier {
  List<ProductDetails> _products = [];
  final ShardModel _userShardModel;

  ShardStoreModel(this._userShardModel);

  List<ProductDetails> get products => _products;

  Future<void> loadProducts() async {
    // For now, use the mock data
    _products = mockProducts;
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (kDebugMode) {
      print("Mock purchase initiated for product: ${product.title}");
    }

    // For now, just mock adding shards based on product ID
    if (product.id == 'shard_package_100') {
      _userShardModel.addShards(100);
    } else if (product.id == 'shard_package_500') {
      _userShardModel.addShards(500);
    }

    notifyListeners();
  }
}

// Mock data for products
List<ProductDetails> mockProducts = [
  ProductDetails(
    id: 'shard_package_100',
    title: '100 Shards',
    description: 'Purchase 100 Shards',
    price: '\$0.99',
    rawPrice: 100,
    currencyCode: '1',
    // You can add other fields if needed
  ),
  ProductDetails(
    id: 'shard_package_500',
    title: '500 Shards',
    description: 'Purchase 500 Shards',
    price: '\$3.99',
    rawPrice: 300,
    currencyCode: '2',
    // You can add other fields if needed
  ),
  // Add more mock products as needed
];
