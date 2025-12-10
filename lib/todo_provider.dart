import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'todo_model.dart';

class TodoProvider extends ChangeNotifier {
  final _db = Localstore.instance;

  List<Expense> _expenses = [];
  List<Category> _categories = [];

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- TÍNH TOÁN TỔNG TIỀN (Logic mới) ---
  double get totalSpent {
    double total = 0;
    for (var item in _expenses) {
      total += item.amount;
    }
    return total;
  }

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    // Load Categories
    final catItems = await _db.collection('categories').get();
    if (catItems != null && catItems.isNotEmpty) {
      _categories = catItems.entries.map((e) => Category.fromMap(e.value)).toList();
    } else {
      // Tạo danh mục mặc định cho App chi tiêu
      await addCategory("Ăn uống");
      await addCategory("Đi lại");
      await addCategory("Mua sắm");
    }

    // Load Expenses
    final expenseItems = await _db.collection('expenses').get();
    if (expenseItems != null) {
      _expenses = expenseItems.entries.map((e) => Expense.fromMap(e.value)).toList();
      _expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final id = _db.collection('categories').doc().id;
    final newCat = Category(id: id, name: name);
    await newCat.saveToCollection('categories');
    _categories.add(newCat);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
    _categories.removeWhere((c) => c.id == id);
    // Xóa luôn các khoản chi thuộc danh mục này
    final toDelete = _expenses.where((t) => t.categoryId == id).toList();
    for (var t in toDelete) {
      await _db.collection('expenses').doc(t.id).delete();
    }
    _expenses.removeWhere((t) => t.categoryId == id);
    notifyListeners();
  }

  // --- CRUD KHOẢN CHI ---
  Future<void> addExpense(String title, String desc, double amount, String catId) async {
    final id = _db.collection('expenses').doc().id;
    final newItem = Expense(
      id: id,
      title: title,
      description: desc,
      amount: amount,
      categoryId: catId,
      createdAt: DateTime.now(),
    );
    await newItem.saveToCollection('expenses');
    _expenses.insert(0, newItem);
    notifyListeners();
  }

  Future<void> updateExpense(Expense item, String title, String desc, double amount, String catId) async {
    item.title = title;
    item.description = desc;
    item.amount = amount;
    item.categoryId = catId;
    await item.saveToCollection('expenses');
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
    _expenses.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  String getCategoryName(String catId) {
    try {
      return _categories.firstWhere((c) => c.id == catId).name;
    } catch (e) {
      return "Khác";
    }
  }
}