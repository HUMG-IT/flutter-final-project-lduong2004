import 'package:localstore/localstore.dart';

// --- MODEL 1: DANH MỤC ---
class Category {
  final String id;
  String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}

// --- MODEL 2: CÔNG VIỆC ---
class Todo {
  final String id;
  String title;
  String description;
  bool isDone;
  final DateTime createdAt;
  String categoryId; // Liên kết với Category

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    required this.createdAt,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'categoryId': categoryId,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      categoryId: map['categoryId'] ?? '',
    );
  }
}

// Extension lưu trữ chung
extension ExtLocalStore on Object {
  Future saveToCollection(String collection) async {
    final db = Localstore.instance;
    // Tự động detect loại object để lấy ID (đơn giản hóa)
    if (this is Category) {
      return db.collection(collection).doc((this as Category).id).set((this as Category).toMap());
    } else if (this is Todo) {
      return db.collection(collection).doc((this as Todo).id).set((this as Todo).toMap());
    }
  }

  Future deleteFromCollection(String collection, String id) async {
    return Localstore.instance.collection(collection).doc(id).delete();
  }
}