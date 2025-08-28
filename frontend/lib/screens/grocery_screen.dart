import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';
import '../widgets/chips_suggestions.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final _newCtrl = TextEditingController();
  final _uuid = const Uuid();
  List<GroceryItem> _items = [];
  bool _loading = false;
  String? token;

  // Use a more flexible base URL that works for both web and mobile
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  @override
  void initState() {
    super.initState();
    _loadTokenAndItems();
  }

  Future<void> _loadTokenAndItems() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    if (storedToken == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    setState(() => token = storedToken);
    await _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _loading = true);

    try {
      final res = await http.get(Uri.parse('$baseUrl/grocery'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (res.statusCode == 200) {
        final List<dynamic> itemsJson = json.decode(res.body);
        setState(() {
          _items = itemsJson.map((json) => GroceryItem.fromJson(json as Map<String, dynamic>)).toList();
        });
      }
    } catch (e) {
      print('Error fetching grocery items: $e');
    }

    setState(() => _loading = false);
  }

  Future<void> _addItem() async {
    if (_newCtrl.text.trim().isEmpty) return;

    final newItem = GroceryItem(
      id: _uuid.v4(),
      name: _newCtrl.text.trim(),
      qty: 1,
      category: 'General',
      checked: false,
    );

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/grocery'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(newItem.toJson()),
      );

      if (res.statusCode == 201) {
        final addedItem = GroceryItem.fromJson(json.decode(res.body) as Map<String, dynamic>);
        setState(() => _items.add(addedItem));
        _newCtrl.clear();
      }
    } catch (e) {
      print('Error adding grocery item: $e');
    }
  }

  Future<void> _toggleItem(GroceryItem item) async {
    final updatedItem = item.copyWith(checked: !item.checked);

    try {
      final res = await http.put(
        Uri.parse("$baseUrl/grocery/${item.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedItem.toJson()),
      );

      if (res.statusCode == 200) {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          setState(() => _items[index] = updatedItem);
        }
      }
    } catch (e) {
      print('Error updating grocery item: $e');
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/grocery/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        setState(() => _items.removeWhere((item) => item.id == id));
      }
    } catch (e) {
      print('Error deleting grocery item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grocery List',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            '${_items.where((item) => !item.checked).length} items remaining',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Add item input
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _newCtrl,
                          decoration: InputDecoration(
                            hintText: 'Add grocery item...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            suffixIcon: IconButton(
                              onPressed: _addItem,
                              icon: Icon(
                                Icons.add_circle,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _addItem(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Grocery items list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No grocery items yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add items to your shopping list',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: item.checked
                                        ? Colors.grey[400]!
                                        : Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                  color: item.checked
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                ),
                                child: item.checked
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.checked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.checked
                                      ? Colors.grey[600]
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${item.qty}x • ${item.category ?? 'General'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () => _deleteItem(item.id),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                ),
                              ),
                              onTap: () => _toggleItem(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
