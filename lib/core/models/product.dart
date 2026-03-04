import 'dart:ui';

enum KOTCategory { kitchen, bar, sushi, dessert }

class ProductModifier {
  final String id;
  final String name;
  final double extraPrice;

  ProductModifier({required this.id, required this.name, this.extraPrice = 0.0});
}

class Product {
  final String id;
  final String name;
  final String? description; 
  final int? quantity;
  final double? price; 
  final Color? color; 
  final KOTCategory kotCategory;
  final List<ProductModifier> selectedModifiers;
  final String? specialInstructions;
  final String? size; // Small, Medium, Large

  Product({
    required this.id, 
    required this.name, 
    this.description,
    this.quantity, 
    required this.price, 
    required this.color,
    this.kotCategory = KOTCategory.kitchen,
    this.selectedModifiers = const [],
    this.specialInstructions,
    this.size,
  });

  Product copyWith({
    String? id, 
    String? name, 
    String? description,
    int? quantity, 
    double? price, 
    Color? color,
    KOTCategory? kotCategory,
    List<ProductModifier>? selectedModifiers,
    String? specialInstructions,
    String? size,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity, 
      price: price ?? this.price,
      color: color ?? this.color,
      kotCategory: kotCategory ?? this.kotCategory,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      size: size ?? this.size,
    );
  }

  double get totalUnitPrice {
    double modPrice = selectedModifiers.fold(0, (sum, mod) => sum + mod.extraPrice);
    return (price ?? 0) + modPrice;
  }
}
