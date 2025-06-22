import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ExpenseModel.dart';

class FinanceGraphScreen extends StatelessWidget {
  final List<Expense> expenses;

  const FinanceGraphScreen({super.key, required this.expenses});

  Map<String, double> calculateTotals(List<Expense> data) {
    double incomeTotal = 0;
    double expenseTotal = 0;

    for (var e in data) {
      final amt = double.tryParse(e.amount) ?? 0;
      if (e.income) incomeTotal += amt;
      if (e.expense) expenseTotal += amt;
    }

    return {
      'income': incomeTotal,
      'expense': expenseTotal,
      'netWorth': incomeTotal - expenseTotal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals(expenses);

    final income = totals['income']!;
    final expense = totals['expense']!;
    final netWorth = totals['netWorth']!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Summary Graph'),
        backgroundColor: Color(0xFFDAA67B),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Finance Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: [income, expense, netWorth].reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text('Income');
                                case 1:
                                  return Text('Expense');
                                case 2:
                                  return Text('Net Worth');
                                default:
                                  return Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: income, color: Colors.green),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(toY: expense, color: Colors.red),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: netWorth >= 0 ? netWorth : 0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text('Income: \$${income.toStringAsFixed(2)}'),
                Text('Expense: \$${expense.toStringAsFixed(2)}'),
                Text('Net Worth: \$${netWorth.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
