import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'todo_model.dart';

class TodoProvider extends ChangeNotifier {
  final _db = Localstore.instance;

  List<Todo> _todos = [];
  List<Category> _categories = [];

  List<Todo> get todos => _todos;
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- KHỞI TẠO DỮ LIỆU ---
  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Tải Danh mục
    final catItems = await _db.collection('categories').get();
    if (catItems != null && catItems.isNotEmpty) {
      _categories = catItems.entries.map((e) => Category.fromMap(e.value)).toList();
    } else {
      // Nếu chưa có danh mục nào, tạo mặc định 1 cái
      await addCategory("Công việc chung");
    }

    // 2. Tải Công việc
    final todoItems = await _db.collection('todos').get();
    if (todoItems != null) {
      _todos = todoItems.entries.map((e) => Todo.fromMap(e.value)).toList();
      _todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- XỬ LÝ CATEGORY (CRUD 1) ---
  Future<void> addCategory(String name) async {
    final id = _db.collection('categories').doc().id;
    final newCat = Category(id: id, name: name);
    await newCat.saveToCollection('categories');
    _categories.add(newCat);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    // Xóa danh mục
    await _db.collection('categories').doc(id).delete();
    _categories.removeWhere((c) => c.id == id);

    // Logic phụ: Xóa luôn các công việc thuộc danh mục đó (Cascade Delete)
    // Hoặc chuyển nó về danh mục khác. Ở đây ta chọn xóa luôn cho sạch.
    final todosToDelete = _todos.where((t) => t.categoryId == id).toList();
    for (var t in todosToDelete) {
      await _db.collection('todos').doc(t.id).delete();
    }
    _todos.removeWhere((t) => t.categoryId == id);

    notifyListeners();
  }

  // --- XỬ LÝ TODO (CRUD 2) ---
  Future<void> addTodo(String title, String desc, String catId) async {
    final id = _db.collection('todos').doc().id;
    final newTodo = Todo(
      id: id,
      title: title,
      description: desc,
      categoryId: catId,
      createdAt: DateTime.now(),
    );
    await newTodo.saveToCollection('todos');
    _todos.insert(0, newTodo);
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo, String title, String desc, String catId) async {
    todo.title = title;
    todo.description = desc;
    todo.categoryId = catId;
    await todo.saveToCollection('todos');
    notifyListeners();
  }

  Future<void> toggleStatus(Todo todo) async {
    todo.isDone = !todo.isDone;
    await todo.saveToCollection('todos');
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await _db.collection('todos').doc(id).delete();
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Helper lấy tên danh mục từ ID
  String getCategoryName(String catId) {
    try {
      return _categories.firstWhere((c) => c.id == catId).name;
    } catch (e) {
      return "Không xác định";
    }
  }
}