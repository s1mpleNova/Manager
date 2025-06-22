import 'package:assi/AddExpense.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ExpenseModel.dart';
import 'GraphScreen.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  List<Expense> expenses = [];
  bool isFiltered = false;
  List<Expense> filteredExpenses = [];
  bool showGraph = false;

  Future<void> loadExpensesFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedExpenses = prefs.getStringList('expenses') ?? [];

    setState(() {
      expenses = storedExpenses.map((e) => Expense.fromJson(e)).toList();
    });
  }

  List<Expense> filterExpenses({
    double? minAmount,
    double? maxAmount,
    DateTime? date,
    bool? isIncome, // true = income only, false = expense only
    String sortBy = 'none', // 'asc', 'desc', or 'none'
  }) {
    List<Expense> filtered = [...expenses];

    // Filter by amount range
    if (minAmount != null || maxAmount != null) {
      filtered = filtered.where((expense) {
        double amount = double.tryParse(expense.amount) ?? 0;
        bool inMin = minAmount == null || amount >= minAmount;
        bool inMax = maxAmount == null || amount <= maxAmount;
        return inMin && inMax;
      }).toList();
    }

    // Filter by date
    if (date != null) {
      final formattedFilterDate = DateFormat('yyyy-MM-dd').format(date);
      filtered = filtered
          .where((expense) => expense.date == formattedFilterDate)
          .toList();
    }

    // Filter by income or expense
    if (isIncome != null) {
      filtered = filtered
          .where((expense) => isIncome ? expense.income : expense.expense)
          .toList();
    }

    // Sort by amount
    if (sortBy == 'asc') {
      filtered.sort(
        (a, b) => (double.tryParse(a.amount) ?? 0).compareTo(
          double.tryParse(b.amount) ?? 0,
        ),
      );
    } else if (sortBy == 'desc') {
      filtered.sort(
        (a, b) => (double.tryParse(b.amount) ?? 0).compareTo(
          double.tryParse(a.amount) ?? 0,
        ),
      );
    }

    return filtered;
  }

  void editExpense(int index, Expense updatedExpense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedExpenses = prefs.getStringList('expenses') ?? [];
    if (index >= 0 && index < storedExpenses.length) {
      storedExpenses[index] = updatedExpense.toJson(); // Update the item
      await prefs.setStringList('expenses', storedExpenses); // Save list

      setState(() {
        expenses[index] = updatedExpense; // Update UI
      });
    }
  }

  void deleteExpense(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Choose the list currently displayed
    List<Expense> listToModify = isFiltered ? filteredExpenses : expenses;

    if (index < 0 || index >= listToModify.length) return;

    Expense expenseToRemove = listToModify[index];

    // Remove from the filtered list (if filtered)
    setState(() {
      listToModify.removeAt(index);
      if (isFiltered) {
        // Also remove from main expenses list
        expenses.removeWhere((e) =>
        e.amount == expenseToRemove.amount &&
            e.description == expenseToRemove.description &&
            e.category == expenseToRemove.category &&
            e.date == expenseToRemove.date &&
            e.income == expenseToRemove.income &&
            e.expense == expenseToRemove.expense
        );
      }
    });

    // Remove from SharedPreferences by matching serialized JSON string
    List<String> storedExpenses = prefs.getStringList('expenses') ?? [];
    storedExpenses.removeWhere((jsonStr) {
      Expense e = Expense.fromJson(jsonStr);
      return e.amount == expenseToRemove.amount &&
          e.description == expenseToRemove.description &&
          e.category == expenseToRemove.category &&
          e.date == expenseToRemove.date &&
          e.income == expenseToRemove.income &&
          e.expense == expenseToRemove.expense;
    });

    await prefs.setStringList('expenses', storedExpenses);

    // If filtered, update filteredExpenses state as well
    if (isFiltered) {
      setState(() {
        filteredExpenses = filteredExpenses.where((e) => e != expenseToRemove).toList();
      });
    }
  }


  @override
  void initState() {
    super.initState();
    loadExpensesFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finance Calculator"),
        backgroundColor: Color(0xFFDAA67B),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                 Get.to(()=> FinanceGraphScreen(
                   expenses: isFiltered ? filteredExpenses : expenses,
                 ));
                },
                icon: Icon(Icons.auto_graph_rounded),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final filters = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) {
                      // Controllers and state for dialog inputs
                      final minAmountController = TextEditingController();
                      final maxAmountController = TextEditingController();
                      DateTime? selectedDate;
                      bool? isIncome; // null means both
                      String sortBy = 'none';

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Filter Expenses'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Min Amount
                                  TextField(
                                    controller: minAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Min Amount',
                                    ),
                                  ),
                                  // Max Amount
                                  TextField(
                                    controller: maxAmountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Max Amount',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Date Picker
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedDate == null
                                              ? 'No date selected'
                                              : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                                        ),
                                      ),
                                      TextButton(
                                        child: Text('Pick Date'),
                                        onPressed: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                selectedDate ?? DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date;
                                            });
                                          }
                                        },
                                      ),
                                      if (selectedDate != null)
                                        IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              selectedDate = null;
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Income / Expense / Both Radio Buttons
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Transaction Type'),
                                      Row(
                                        children: [
                                          Radio<bool?>(
                                            value: null,
                                            groupValue: isIncome,
                                            onChanged: (val) =>
                                                setState(() => isIncome = val),
                                          ),
                                          Text('Both'),
                                          Radio<bool?>(
                                            value: true,
                                            groupValue: isIncome,
                                            onChanged: (val) =>
                                                setState(() => isIncome = val),
                                          ),
                                          Text('Income'),
                                          Radio<bool?>(
                                            value: false,
                                            groupValue: isIncome,
                                            onChanged: (val) =>
                                                setState(() => isIncome = val),
                                          ),
                                          Text('Expense'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Sort By Dropdown
                                  DropdownButtonFormField<String>(
                                    value: sortBy,
                                    decoration: InputDecoration(
                                      labelText: 'Sort By Amount',
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'none',
                                        child: Text('None'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'asc',
                                        child: Text('Ascending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'desc',
                                        child: Text('Descending'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        sortBy = val ?? 'none';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              ElevatedButton(
                                child: Text('Apply'),
                                onPressed: () {
                                  Navigator.pop(context, {
                                    'minAmount':
                                        minAmountController.text.isNotEmpty
                                        ? double.tryParse(
                                            minAmountController.text,
                                          )
                                        : null,
                                    'maxAmount':
                                        maxAmountController.text.isNotEmpty
                                        ? double.tryParse(
                                            maxAmountController.text,
                                          )
                                        : null,
                                    'date': selectedDate,
                                    'isIncome': isIncome,
                                    'sortBy': sortBy,
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );

                  if (filters != null) {
                    setState(() {
                      filteredExpenses = filterExpenses(
                        minAmount: filters['minAmount'],
                        maxAmount: filters['maxAmount'],
                        date: filters['date'],
                        isIncome: filters['isIncome'],
                        sortBy: filters['sortBy'],
                      );
                      isFiltered = true;
                    });
                  }
                },
                icon: Icon(Icons.filter_alt_sharp),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadExpensesFromPrefs,
        child: (isFiltered ? filteredExpenses : expenses).isEmpty
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: Text("No expenses found.")),
            ),
          ],
        )
            : ListView.builder(
          itemCount: (isFiltered ? filteredExpenses : expenses).length,
          itemBuilder: (context, index) {
            final dataList = isFiltered ? filteredExpenses : expenses;
            final expense = dataList[index];
            return Dismissible(
              key: Key(expense.date + expense.amount + index.toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => deleteExpense(index),
              child: Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("\$${expense.amount} - ${expense.category}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${expense.description}\nDate: ${expense.date}"),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          if (expense.income)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Income',
                                style: TextStyle(color: Colors.green[900]),
                              ),
                            ),
                          if (expense.expense)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: EdgeInsets.only(left: 0),
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Expense',
                                style: TextStyle(color: Colors.red[900]),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          bool? edited = await Get.to(() => AddExpense(
                            expenseToEdit: expense,
                            expenseIndex: index,
                          ));
                          if (edited == true) {
                            await loadExpensesFromPrefs();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteExpense(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? added = await Get.to(() => AddExpense());
          if (added == true) {
            await loadExpensesFromPrefs(); // refresh after adding
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
