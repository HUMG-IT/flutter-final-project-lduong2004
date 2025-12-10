import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_provider.dart';
import 'todo_model.dart';
import 'package:intl/intl.dart'; // Để format tiền (VD: 50,000)

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TodoProvider>(context, listen: false).initData();
  }

  // Hàm format tiền tệ cho đẹp (ví dụ: 50000 -> 50,000 đ)
  String formatCurrency(double amount) {
    final formatter = NumberFormat("#,###");
    return "${formatter.format(amount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền xám nhẹ
      appBar: AppBar(
        title: const Text('Sổ Thu Chi Cá Nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: const CategoryDrawer(),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              // --- PHẦN 1: DASHBOARD TỔNG QUAN ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.teal, Colors.greenAccent]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    const Text("Tổng chi tiêu tháng này", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(
                      formatCurrency(provider.totalSpent),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // --- PHẦN 2: DANH SÁCH CHI TIÊU ---
              Expanded(
                child: provider.expenses.isEmpty
                    ? const Center(child: Text("Chưa có khoản chi nào. Hãy thêm mới!", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.expenses.length,
                  itemBuilder: (context, index) {
                    final item = provider.expenses[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: const Icon(Icons.monetization_on, color: Colors.teal),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${provider.getCategoryName(item.categoryId)} • ${item.description}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency(item.amount),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Nút xóa nhỏ
                            InkWell(
                              onTap: () => provider.deleteExpense(item.id),
                              child: const Icon(Icons.delete_forever, size: 18, color: Colors.grey),
                            )
                          ],
                        ),
                        onTap: () => showExpenseDialog(context, item: item),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExpenseDialog(context),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("Thêm khoản chi"),
      ),
    );
  }
}

// --- DRAWER QUẢN LÝ DANH MỤC (GIỮ NGUYÊN LOGIC, CHỈ ĐỔI MÀU) ---
class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final txtController = TextEditingController();

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            color: Colors.teal,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: const Text("Danh mục chi tiêu", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: provider.categories.length,
              itemBuilder: (ctx, i) {
                final cat = provider.categories[i];
                return ListTile(
                  leading: const Icon(Icons.category, color: Colors.teal),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => provider.deleteCategory(cat.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: txtController, decoration: const InputDecoration(hintText: 'Thêm danh mục...', border: OutlineInputBorder()))),
                IconButton(icon: const Icon(Icons.add_circle, size: 40, color: Colors.teal), onPressed: () {
                  if (txtController.text.isNotEmpty) {
                    provider.addCategory(txtController.text);
                    txtController.clear();
                  }
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- DIALOG THÊM KHOẢN CHI (CÓ NHẬP SỐ TIỀN) ---
void showExpenseDialog(BuildContext context, {Expense? item}) {
  final provider = Provider.of<TodoProvider>(context, listen: false);
  final isEditing = item != null;

  final titleCtrl = TextEditingController(text: isEditing ? item.title : '');
  final descCtrl = TextEditingController(text: isEditing ? item.description : '');
  final amountCtrl = TextEditingController(text: isEditing ? item.amount.toInt().toString() : '');

  String selectedCatId = isEditing ? item.categoryId : (provider.categories.isNotEmpty ? provider.categories.first.id : '');

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEditing ? 'Sửa khoản chi' : 'Thêm khoản chi mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên khoản chi (VD: Ăn trưa) *')),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Số tiền (VD: 30000) *', suffixText: 'đ'),
                  keyboardType: TextInputType.number, // Chỉ cho nhập số
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCatId.isNotEmpty ? selectedCatId : null,
                  decoration: const InputDecoration(labelText: 'Loại chi tiêu', border: OutlineInputBorder()),
                  items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) { if (val != null) setState(() => selectedCatId = val); },
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty || selectedCatId.isEmpty) return;

                double amount = double.tryParse(amountCtrl.text) ?? 0;

                if (isEditing) {
                  provider.updateExpense(item, titleCtrl.text, descCtrl.text, amount, selectedCatId);
                } else {
                  provider.addExpense(titleCtrl.text, descCtrl.text, amount, selectedCatId);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    ),
  );
}