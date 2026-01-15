import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/stock_history.dart';

class StockHistoryScreen extends StatefulWidget {
  final String productId;

  const StockHistoryScreen({super.key, required this.productId});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  List<StockHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DBHelper.getStockHistory(widget.productId);
    setState(() {
      _history = data.map((e) => StockHistory.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock History')),
      body: _history.isEmpty
          ? const Center(child: Text('No stock changes yet'))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (_, index) {
          final item = _history[index];
          final date =
          DateFormat('dd MMM yyyy, hh:mm a').format(item.timestamp);

          return ListTile(
            leading: Icon(
              item.change > 0 ? Icons.add_circle : Icons.remove_circle,
              color: item.change > 0 ? Colors.green : Colors.red,
            ),
            title: Text(
              item.change > 0
                  ? '+${item.change} added'
                  : '${item.change} removed',
            ),
            subtitle: Text(date),
          );
        },
      ),
    );
  }
}
