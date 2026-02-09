class Category {
  final int? id;
  final String name;
  final String? color; // hex string like "#FF0000"
  final String? icon;  // icon name like "restaurant"

  Category({
    this.id,
    required this.name,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      icon: map['icon'] as String?,
    );
  }
}
