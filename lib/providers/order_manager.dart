import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_item.dart';

class OrderManager extends ChangeNotifier {
  final List<OrderItem> _items = [];

  List<OrderItem> get items => List.unmodifiable(_items);

  void addItem(OrderItem item) {
    final existingIndex = _items.indexWhere((existing) => existing.id == item.id);

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = OrderItem(
        id: existing.id,
        nameJa: existing.nameJa,
        nameEn: existing.nameEn,
        nameZh: existing.nameZh,
        nameKo: existing.nameKo,
        price: existing.price,
        quantity: existing.quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }

    final current = _items[index];
    _items[index] = OrderItem(
      id: current.id,
      nameJa: current.nameJa,
      nameEn: current.nameEn,
      nameZh: current.nameZh,
      nameKo: current.nameKo,
      price: current.price,
      quantity: current.quantity + 1,
    );

    notifyListeners();
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }

    final current = _items[index];
    if (current.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = OrderItem(
        id: current.id,
        nameJa: current.nameJa,
        nameEn: current.nameEn,
        nameZh: current.nameZh,
        nameKo: current.nameKo,
        price: current.price,
        quantity: current.quantity - 1,
      );
    }

    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int getTotalItems() {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  int getTotalPrice() {
    return _items.fold<int>(0, (sum, item) => sum + item.price * item.quantity);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((item) => item.toJson()).toList();
    await prefs.setString('order_items', jsonEncode(data));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('order_items');

    if (encoded == null || encoded.isEmpty) {
      _items.clear();
      notifyListeners();
      return;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        _items.clear();
        notifyListeners();
        return;
      }

      _items
        ..clear()
        ..addAll(
          decoded.map<OrderItem>((item) {
            if (item is Map<String, dynamic>) {
              return OrderItem.fromJson(item);
            }
            if (item is Map) {
              return OrderItem.fromJson(Map<String, dynamic>.from(item));
            }
            throw const FormatException('Invalid order item format');
          }).toList(),
        );

      notifyListeners();
    } catch (_) {
      _items.clear();
      notifyListeners();
    }
  }
}
