import 'package:assi/ConstantWidget.dart';
import 'package:assi/FinanceDashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ExpenseModel.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key, this.expenseToEdit, this.expenseIndex});

  final Expense? expenseToEdit;
  final int? expenseIndex;

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  late TextEditingController amountController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  bool income = false;
  bool expense = false;

  DateTime? selectedDate;

  String selectedCategory = 'Food';
  List<String> categories = [
    'Food',
    'Transport',
    'Salary',
    'Rent',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Add Custom...',
  ];

  Future<void> saveDataToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final newExpense = Expense(
      amount: amountController.text,
      description: descriptionController.text,
      category: selectedCategory ?? '',
      income: income,
      expense: expense,
      date:
          selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
              : '',
    );

    List<String> existingExpenses = prefs.getStringList('expenses') ?? [];

    if (widget.expenseToEdit != null && widget.expenseIndex != null) {
      // Update existing expense
      if (widget.expenseIndex! >= 0 &&
          widget.expenseIndex! < existingExpenses.length) {
        existingExpenses[widget.expenseIndex!] = newExpense.toJson();
      }
    } else {
      // Add new expense
      existingExpenses.add(newExpense.toJson());
    }

    await prefs.setStringList('expenses', existingExpenses);
    Get.back(result: true);
  }

  void pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Add Custom Category'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter category name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  String customCategory = controller.text.trim();
                  if (customCategory.isNotEmpty &&
                      !categories.contains(customCategory)) {
                    setState(() {
                      categories.insert(categories.length - 1, customCategory);
                      selectedCategory = customCategory;
                    });
                  } else {
                    // Optional: Show a warning if duplicate
                    Get.snackbar("Duplicate", "Category already exists");
                  }
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      amountController = TextEditingController(text: e.amount);
      descriptionController = TextEditingController(text: e.description);
      selectedCategory = e.category;
      selectedDate = DateFormat('yyyy-MM-dd').parse(e.date);
      // You might want to set income/expense based on your logic if stored
      income = e.income;
      expense = e.expense;
    } else {
      amountController = TextEditingController();
      descriptionController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : 'Select Date';
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense"),
        backgroundColor: Color(0xFFDAA67B),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                "Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Divider(height: 5, thickness: 3),
              SizedBox(height: 16),
              ConstantWidgets.textFieldContainer(
                amountController,
                "Amount",
                1,
                TextInputType.number,
              ),
              SizedBox(height: 16),
              ConstantWidgets.textFieldContainer(
                descriptionController,
                "Description for the Expense",
                3,
                TextInputType.text,
              ),
              SizedBox(height: 16),
              Text(
                "Transaction Type",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Divider(height: 5, thickness: 3),
              SizedBox(height: 16),
              ConstantWidgets.labeledCheckbox(
                value: income,
                onChanged: (newValue) {
                  setState(() {
                    income = newValue ?? false;
                  });
                },
                label: "Income",
              ),

              ConstantWidgets.labeledCheckbox(
                value: expense,
                onChanged: (newValue) {
                  setState(() {
                    expense = newValue ?? false;
                  });
                },
                label: "Expense",
              ),
              SizedBox(height: 16),
              Text(
                "Category Selection",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Divider(height: 5, thickness: 3),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedCategory,
                hint: Text('Select Category'),
                items:
                    categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 20)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == 'Add Custom...') {
                    showAddCategoryDialog();
                  } else {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text(
                "Select Date",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Divider(height: 5, thickness: 3),
              SizedBox(height: 16),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(formattedDate),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: ElevatedButton(
                    onPressed: () async {
                      await saveDataToPrefs();
                      Get.back(result: true);
                    },
                    child: Text("Save"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
