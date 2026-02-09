class CustomerCredit {
  final String customer;
  double balance;

  CustomerCredit({
    required this.customer,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'customer': customer,
      'balance': balance,
    };
  }

  factory CustomerCredit.fromMap(Map<String, dynamic> map) {
    return CustomerCredit(
      customer: map['customer'],
      balance: map['balance'],
    );
  }
}
