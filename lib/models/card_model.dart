class CardModel {
  final int? id;
  final String name;
  final String type;
  final double balance;
  final String logo;

  CardModel({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.logo,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Card name cannot be empty');
    }
    if (balance < 0) {
      throw ArgumentError('Initial balance cannot be negative');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'logo': logo,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: map['balance'] as double,
      logo: map['logo'] as String,
    );
  }

  @override
  String toString() {
    return 'CardModel(id: $id, name: $name, type: $type, balance: $balance, logo: $logo)';
  }

  CardModel copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    String? logo,
  }) {
    return CardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      logo: logo ?? this.logo,
    );
  }
}