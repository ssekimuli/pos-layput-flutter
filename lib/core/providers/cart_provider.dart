import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_desktop_ui/core/models/product.dart';

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  // Adds a product or increases quantity if it already exists
  void addProduct(Product product) {
    final existingIndex = state.indexWhere((item) => item.name == product.name);

    if (existingIndex != -1) {
      // If product exists, increase quantity
      increaseQuantity(state[existingIndex]);
    } else {
      // If new, add to list with quantity 1
      state = [...state, product.copyWith(quantity: 1)];
    }
  }

  void increaseQuantity(Product product) {
    state = [
      for (final item in state)
        if (item.id == product.id)
          item.copyWith(quantity: (item.quantity ?? 0) + 1)
        else
          item,
    ];
  }

  void decreaseQuantity(Product product) {
    state = [
      for (final item in state)
        if (item.id == product.id)
          // Only decrease if quantity > 1, otherwise keep at 1 or use removeProduct
          if ((item.quantity ?? 1) > 1)
            item.copyWith(quantity: item.quantity! - 1)
          else
            item
        else
          item,
    ];
  }

  void removeProduct(Product product) {
    state = state.where((item) => item.id != product.id).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});