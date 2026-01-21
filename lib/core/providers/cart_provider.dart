import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_desktop_ui/core/models/product.dart';

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(int index) {
    state = [...state]..removeAt(index);
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});
