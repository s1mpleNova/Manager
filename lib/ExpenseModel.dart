import 'dart:convert';

class Expense{
  final String amount;
  final String description;
  final String category;
  final bool income;
  final bool expense;
  final String date;

  Expense({
    required this.amount,
    required this.description,
    required this.income,
    required this.expense,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'income': income,
      'expense': expense,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: map['amount'],
      description: map['description'],
      category: map['category'],
      income: map['income'],
      expense: map['expense'],
      date: map['date'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Expense.fromJson(String source) => Expense.fromMap(jsonDecode(source));
}