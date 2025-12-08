import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_provider.dart';
import 'todo_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App (2 Objects)'), elevation: 2),
      // --- MENU QUẢN LÝ DANH MỤC ---
      drawer: const CategoryDrawer(),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          if (provider.todos.isEmpty) {
            return const Center(child: Text('Chưa có công việc nào'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.todos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => provider.toggleStatus(todo),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                      color: todo.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                  // Hiển thị tên Danh mục ở dưới (Chip nhỏ)
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todo.description.isNotEmpty) Text(todo.description),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          provider.getCategoryName(todo.categoryId),
                          style: const TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => showTodoDialog(context, todo: todo),
                  ),
                  onLongPress: () => provider.deleteTodo(todo.id), // Nhấn giữ để xóa nhanh
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- WIDGET DRAWER: QUẢN LÝ DANH MỤC ---
class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final txtController = TextEditingController();

    return Drawer(
      child: Column(
        children: [
          AppBar(title: const Text('Quản lý Danh mục'), automaticallyImplyLeading: false),
          Expanded(
            child: ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (ctx, i) {
                final cat = provider.categories[i];
                return ListTile(
                  leading: const Icon(Icons.folder, color: Colors.orange),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      if (provider.categories.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phải giữ lại ít nhất 1 danh mục!')));
                        return;
                      }
                      provider.deleteCategory(cat.id);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: txtController,
                    decoration: const InputDecoration(hintText: 'Thêm danh mục...', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30, color: Colors.blue),
                  onPressed: () {
                    if (txtController.text.isNotEmpty) {
                      provider.addCategory(txtController.text);
                      txtController.clear();
                    }
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- DIALOG THÊM/SỬA TODO ---
void showTodoDialog(BuildContext context, {Todo? todo}) {
  final provider = Provider.of<TodoProvider>(context, listen: false);
  final isEditing = todo != null;

  final titleCtrl = TextEditingController(text: isEditing ? todo.title : '');
  final descCtrl = TextEditingController(text: isEditing ? todo.description : '');

  // Mặc định chọn category đầu tiên hoặc category cũ
  String selectedCatId = isEditing ? todo.categoryId : (provider.categories.isNotEmpty ? provider.categories.first.id : '');

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder( // Dùng StatefulBuilder để update Dropdown trong Dialog
      builder: (context, setState) {
        return AlertDialog(
          title: Text(isEditing ? 'Sửa công việc' : 'Thêm công việc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Tên công việc *'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                const SizedBox(height: 15),
                // DROPDOWN CHỌN DANH MỤC
                DropdownButtonFormField<String>(
                  value: selectedCatId.isNotEmpty ? selectedCatId : null,
                  decoration: const InputDecoration(labelText: 'Chọn danh mục', border: OutlineInputBorder()),
                  items: provider.categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedCatId = val);
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || selectedCatId.isEmpty) return;

                if (isEditing) {
                  provider.updateTodo(todo, titleCtrl.text, descCtrl.text, selectedCatId);
                } else {
                  provider.addTodo(titleCtrl.text, descCtrl.text, selectedCatId);
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