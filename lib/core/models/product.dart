
import 'dart:ui';

class Product {
  final String id;
  final String name;
  final int? quantity;
  final double? price; // Add price field
  final Color? color; // Add color field
  

  Product({required this.id, required this.name, this.quantity, required this.price, required this.color});

  Product copyWith({String? id, String? name, int? quantity, double? price, Color? color}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity, 
      price: price ?? this.price, // No change needed here
      color: color ?? this.color, // No change needed here
    );
  }
}