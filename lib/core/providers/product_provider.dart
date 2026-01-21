import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_desktop_ui/core/models/product.dart';

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]);

  void setProducts(List<Product> products) {
    state = products;
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  final productNotifier = ProductNotifier();
  productNotifier.setProducts(List.generate(
    20,
    (i) => Product(
      name: i % 2 == 0 ? 'Coffee Mug - 350ml' : 'Espresso Cup',
      price: i % 2 == 0 ? 14.99 : 9.50,
      color: i % 2 == 0
          ? const Color.fromARGB(255, 199, 225, 233)
          : const Color.fromARGB(255, 248, 229, 202),
    ),
  ));
  return productNotifier;
});
