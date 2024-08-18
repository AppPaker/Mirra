import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mirra/src/app/controllers/store/store_model.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../controllers/home/home_page_model.dart';
import '../home/home_page_widget.dart';

List<ProductDetails> mockProducts = [
  ProductDetails(
    id: 'shard_package_100',
    title: '100 Shards',
    description: 'Purchase 100 Shards',
    price: '£0.99', rawPrice: 100, currencyCode: '1',
    // You can add other fields if needed
  ),
  ProductDetails(
    id: 'shard_package_500',
    title: '500 Shards',
    description: 'Purchase 500 Shards',
    price: '£3.99', rawPrice: 300, currencyCode: '2',
    // You can add other fields if needed
  ),
  // Add more mock products as needed
];

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  void initState() {
    super.initState();
    // Load products when the widget is initialized
    Provider.of<ShardStoreModel>(context, listen: false).loadProducts();
  }
/*class _StorePageState extends State<StorePage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // For now, just use the mock data
    setState(() {
      _products = mockProducts;
    });
  }*/

  /*Future<void> _loadProducts() async {
    const Set<String> _kIds = {'shard_package_100', 'shard_package_500'};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle any errors or missing products
    }
    setState(() {
      _products = response.productDetails;
    });
  }*/

  /*Future<void> _buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }*/
  Future<void> _buyProduct(ProductDetails product) async {
    if (kDebugMode) {
      print("Mock purchase initiated for product: ${product.title}");
    }
    // Later, you'll replace this with the actual purchase logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<HomePageViewModel>(
                  create: (_) => HomePageViewModel(
                    authService:
                        Provider.of<AuthService>(context, listen: false),
                  ),
                  child: const HomePage(),
                ),
              ),
            ),
          ),
          title: const Text('Shard Store')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ShardStoreModel>(
          builder: (context, storeModel, child) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: storeModel.products.length,
              itemBuilder: (context, index) {
                final product = storeModel.products[index];
                return Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(
                        1.0), // Add padding to the card's content
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 7),
                        Text(product.description),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () => storeModel.buyProduct(product),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(
                                1.0), // Adjust button padding as needed
                          ),
                          child: Text('Buy for ${product.price}'),
                        ),
                      ],
                    ),
                  ),
                );
                // TODO:Error Handling: Handle errors gracefully. This includes checking if the product is available, if the transaction was successful, etc. Add error handling when integrating the actual purchase logic.
                // TODO:Feedback to the User: After a user makes a purchase, provide feedback, such as a success message or an error message. eg. SnackBar or a dialog to inform the user about the result of their purchase.
              },
            );
          },
        ),
      ),
    );
  }
}
