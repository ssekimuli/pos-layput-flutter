import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

enum TableStatus { available, occupied, reserved, cleaning }
enum TableGroup { regular, vip, outdoor, bar }

class TableModel {
  final String id;
  final String number;
  final int capacity;
  final TableStatus status;
  final TableGroup group;
  final String? activeOrderId;

  TableModel({
    required this.id,
    required this.number,
    this.capacity = 4,
    this.status = TableStatus.available,
    this.group = TableGroup.regular,
    this.activeOrderId,
  });

  TableModel copyWith({
    String? number,
    int? capacity,
    TableStatus? status,
    TableGroup? group,
    String? activeOrderId,
  }) {
    return TableModel(
      id: this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      group: group ?? this.group,
      activeOrderId: activeOrderId ?? this.activeOrderId,
    );
  }
}

class TableNotifier extends StateNotifier<List<TableModel>> {
  TableNotifier() : super(_initialTables());

  void addTable(TableModel table) {
    state = [...state, table];
  }

  void updateTable(TableModel updatedTable) {
    state = [
      for (final t in state)
        if (t.id == updatedTable.id) updatedTable else t
    ];
  }

  void deleteTable(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void updateStatus(String id, TableStatus status, {String? orderId}) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(status: status, activeOrderId: orderId)
        else
          t
    ];
  }

  static List<TableModel> _initialTables() {
    return [
      TableModel(id: '1', number: '1', group: TableGroup.regular, status: TableStatus.available),
      TableModel(id: '2', number: '2', group: TableGroup.regular, status: TableStatus.occupied),
      TableModel(id: '101', number: 'VIP-1', group: TableGroup.vip, status: TableStatus.reserved),
      TableModel(id: '102', number: 'VIP-2', group: TableGroup.vip, status: TableStatus.available),
      TableModel(id: '201', number: 'OUT-1', group: TableGroup.outdoor, status: TableStatus.cleaning),
      TableModel(id: '301', number: 'BAR-1', group: TableGroup.bar, status: TableStatus.available),
    ];
  }
}

final tableProvider = StateNotifierProvider<TableNotifier, List<TableModel>>((ref) {
  return TableNotifier();
});
