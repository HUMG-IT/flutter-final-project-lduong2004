import 'package:localstore/localstore.dart';

// --- MODEL 1: DANH MỤC CHI TIÊU ---
class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}

// --- MODEL 2: KHOẢN CHI ---
class Expense {
  final String id;
  String title;       // Tên khoản chi (vd: Phở bò)
  String description; // Ghi chú (vd: Ăn sáng)
  double amount;      // Số tiền (vd: 35000)
  final DateTime createdAt;
  String categoryId;

  Expense({
    required this.id,
    required this.title,
    this.description = '',
    required this.amount,
    required this.createdAt,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'categoryId': categoryId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      categoryId: map['categoryId'] ?? '',
    );
  }
}

// Extension lưu trữ chung
extension ExtLocalStore on Object {
  Future saveToCollection(String collection) async {
    final db = Localstore.instance;
    if (this is Category) {
      return db.collection(collection).doc((this as Category).id).set((this as Category).toMap());
    } else if (this is Expense) {
      return db.collection(collection).doc((this as Expense).id).set((this as Expense).toMap());
    }
  }
}