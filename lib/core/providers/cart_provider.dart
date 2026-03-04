import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_desktop_ui/core/models/product.dart';

enum CartType { shop, restaurant, hotelBooking, roomService }

class CartMetadata {
  final CartType type;
  final String? targetId; // Table Number, Room Number, or Customer Name
  final String? secondaryId; // Guest Name for Hotel

  CartMetadata({
    required this.type,
    this.targetId,
    this.secondaryId,
  });

  String get displayName {
    switch (type) {
      case CartType.shop: return "New Sale";
      case CartType.restaurant: return "Table ${targetId ?? 'N/A'}";
      case CartType.hotelBooking: return "Booking Room ${targetId ?? 'N/A'}";
      case CartType.roomService: return "Room ${targetId ?? 'N/A'} Service";
    }
  }
}

class CartState {
  final List<Product> items;
  final CartMetadata metadata;

  CartState({
    required this.items,
    required this.metadata,
  });

  CartState copyWith({
    List<Product>? items,
    CartMetadata? metadata,
  }) {
    return CartState(
      items: items ?? this.items,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState(
    items: [],
    metadata: CartMetadata(type: CartType.shop),
  ));

  void setMetadata(CartMetadata metadata) {
    state = state.copyWith(metadata: metadata);
  }

  void addProduct(Product product) {
    final existingIndex = state.items.indexWhere((item) => item.name == product.name);

    if (existingIndex != -1) {
      increaseQuantity(state.items[existingIndex]);
    } else {
      state = state.copyWith(
        items: [...state.items, product.copyWith(quantity: 1)],
      );
    }
  }

  void increaseQuantity(Product product) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == product.id)
            item.copyWith(quantity: (item.quantity ?? 0) + 1)
          else
            item,
      ],
    );
  }

  void decreaseQuantity(Product product) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == product.id)
            if ((item.quantity ?? 1) > 1)
              item.copyWith(quantity: item.quantity! - 1)
            else
              item
          else
            item,
      ],
    );
  }

  void removeProduct(Product product) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != product.id).toList(),
    );
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }

  void resetCart(CartType type, {String? targetId}) {
    state = CartState(
      items: [],
      metadata: CartMetadata(type: type, targetId: targetId),
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
