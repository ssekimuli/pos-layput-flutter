import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_desktop_ui/core/models/product.dart';
import 'package:uuid/uuid.dart';

enum CartType { shop, restaurant, hotelBooking, roomService }
enum OrderStatus { pending, preparing, served, paid, cancelled }

class CartMetadata {
  final String orderId;
  final CartType type;
  final String? targetId; 
  final String? secondaryId; 
  final OrderStatus status;
  final String servedBy;
  final DateTime createdAt;

  CartMetadata({
    required this.orderId,
    required this.type,
    this.targetId,
    this.secondaryId,
    this.status = OrderStatus.pending,
    this.servedBy = "Admin",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayName {
    switch (type) {
      case CartType.shop: return "New Sale";
      case CartType.restaurant: return "Table ${targetId ?? 'N/A'}";
      case CartType.hotelBooking: return "Booking Room ${targetId ?? 'N/A'}";
      case CartType.roomService: return "Room ${targetId ?? 'N/A'} Service";
    }
  }

  CartMetadata copyWith({
    OrderStatus? status,
    String? servedBy,
    String? targetId,
    String? orderId,
  }) {
    return CartMetadata(
      orderId: orderId ?? this.orderId,
      type: this.type,
      targetId: targetId ?? this.targetId,
      secondaryId: this.secondaryId,
      status: status ?? this.status,
      servedBy: servedBy ?? this.servedBy,
      createdAt: this.createdAt,
    );
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
    metadata: CartMetadata(orderId: const Uuid().v4(), type: CartType.shop),
  ));

  void setMetadata(CartMetadata metadata) {
    state = state.copyWith(metadata: metadata);
  }

  void updateType(CartType type, {String? targetId}) {
    state = state.copyWith(
      metadata: state.metadata.copyWith(
        orderId: state.metadata.orderId,
        targetId: targetId ?? state.metadata.targetId,
      ),
    );
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

  void updateProductInstructions(Product product, String instructions) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == product.id)
            item.copyWith(specialInstructions: instructions)
          else
            item,
      ],
    );
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }

  void resetCart(CartType type, {String? targetId}) {
    state = CartState(
      items: [],
      metadata: CartMetadata(orderId: const Uuid().v4(), type: type, targetId: targetId),
    );
  }

  void loadOrder(CartState order) {
    state = order;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Provider to manage the collection of all active (non-paid) orders
class ActiveOrdersNotifier extends StateNotifier<List<CartState>> {
  ActiveOrdersNotifier() : super(_dummyOrders());

  void upsertOrder(CartState order) {
    final index = state.indexWhere((o) => o.metadata.orderId == order.metadata.orderId);
    if (index != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) order else state[i]
      ];
    } else {
      state = [...state, order];
    }
  }

  void removeOrder(String orderId) {
    state = state.where((o) => o.metadata.orderId != orderId).toList();
  }

  static List<CartState> _dummyOrders() {
    final uuid = const Uuid();
    return [
      CartState(
        metadata: CartMetadata(orderId: uuid.v4(), type: CartType.restaurant, targetId: "Table 4", status: OrderStatus.preparing, servedBy: "John"),
        items: [Product(id: '1', name: 'Pizza Margherita', price: 12.0, color: Colors.red, quantity: 2)],
      ),
      CartState(
        metadata: CartMetadata(orderId: uuid.v4(), type: CartType.hotelBooking, targetId: "102", status: OrderStatus.pending, servedBy: "Sarah"),
        items: [Product(id: 'ROOM-102', name: 'Room 102 (Deluxe)', price: 150.0, color: Colors.blue, quantity: 1)],
      ),
      CartState(
        metadata: CartMetadata(orderId: uuid.v4(), type: CartType.roomService, targetId: "204", status: OrderStatus.served, servedBy: "Mike"),
        items: [Product(id: '2', name: 'Club Sandwich', price: 15.0, color: Colors.orange, quantity: 1)],
      ),
    ];
  }
}

final activeOrdersProvider = StateNotifierProvider<ActiveOrdersNotifier, List<CartState>>((ref) {
  return ActiveOrdersNotifier();
});
