class Category {
  final int? id;
  final String name;
  final String? color;
  final String? icon;
  int productCount;   // <‑‑ NEW FIELD

  Category({
    this.id,
    required this.name,
    this.color,
    this.icon,
    this.productCount = 0,
  });

  Category copyWith({
    int? id,
    String? name,
    String? color,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    String? icon = map['icon'] as String?;

    if (icon != null && !icon.contains('.')) {
      icon = "$icon.png";
    }

    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      icon: icon,
    );
  }
}