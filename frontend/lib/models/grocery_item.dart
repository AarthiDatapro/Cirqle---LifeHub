class GroceryItem {
  final String id;
  final String name;
  final int qty;
  final bool checked;
  final String? category;

  GroceryItem({
    required this.id,
    required this.name,
    this.qty = 1,
    this.checked = false,
    this.category,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    int? qty,
    bool? checked,
    String? category,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      checked: checked ?? this.checked,
      category: category ?? this.category,
    );
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      qty: (json['qty'] ?? json['quantity'] ?? 1) as int,
      checked: (json['checked'] ?? json['completed'] ?? false) as bool,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qty': qty,
      'checked': checked,
      if (category != null) 'category': category,
    };
  }

  // Backwards-compat getters used in redesigned UI
  int get quantity => qty;
  bool get completed => checked;
}
