import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final Color color;
  final String description;

  Product({
    required this.name,
    required this.price,
    required this.color,
    this.description = "No description provided.",
  });
}