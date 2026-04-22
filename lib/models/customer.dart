class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? address;   // <-- NEW FIELD
  final double balance;
  final String? notes;
  final double initialBalance;
final String? initialBalanceDate;


 Customer({
  this.id,
  required this.name,
  this.phone,
  this.address,
  this.notes,
  required this.balance,
  required this.initialBalance,
  this.initialBalanceDate,
});


  Customer copyWith({
  int? id,
  String? name,
  String? phone,
  String? address,
  String? notes,
  double? balance,
  double? initialBalance,
  String? initialBalanceDate,
}) {
  return Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    notes: notes ?? this.notes,
    balance: balance ?? this.balance,
    initialBalance: initialBalance ?? this.initialBalance,
    initialBalanceDate: initialBalanceDate ?? this.initialBalanceDate,
  );
}


  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'notes': notes,
    'balance': balance,
    'initial_balance': initialBalance,
    'initial_balance_date': initialBalanceDate,
  };
}


  factory Customer.fromMap(Map<String, dynamic> map) {
  return Customer(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    address: map['address'],
    notes: map['notes'],
    balance: (map['balance'] as num).toDouble(),
    initialBalance: (map['initial_balance'] as num?)?.toDouble() ?? 0,
    initialBalanceDate: map['initial_balance_date'],
  );
}

}
