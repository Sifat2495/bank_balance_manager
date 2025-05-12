import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';
import 'add_card_dialog.dart';
import 'transaction_dialog.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CardModel> cards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() => _isLoading = true);
      final loadedCards = await DatabaseHelper.instance.getAllCards();
      setState(() {
        cards = loadedCards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load cards');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showTransactionHistory(CardModel card) async {
    final transactions = await DatabaseHelper.instance.getTransactionsForCard(card.id!);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transactions for ${card.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final formattedDate = DateFormat('dd-MM-yyyy;hh:mm a').format(DateTime.parse(transaction['date']));
              return ListTile(
                title: Text(transaction['type']),
                subtitle: Text(formattedDate),
                trailing: Text('${transaction['amount']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllTransactions() async {
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Transactions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final formattedDate = DateFormat('dd-MM-yyyy;hh:mm a').format(DateTime.parse(transaction['date']));
              return ListTile(
                title: Text(transaction['card_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['type']),
                    Text(formattedDate),
                  ],
                ),
                trailing: Text('${transaction['amount']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final totalBalance = cards.fold(0.0, (sum, card) => sum + card.balance);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Card Balance Tracker'), titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Arial',
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: Colors.white,
            onPressed: _showAllTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : cards.isEmpty
                ? const Center(child: Text('No cards added yet'))
                : ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.asset(card.logo, width: 40, height: 40),
                    title: Text(card.name),
                    subtitle: Text(card.type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${card.balance.toStringAsFixed(0)}/-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.local_atm),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showTransactionDialog(card),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    onTap: () => _showTransactionHistory(card),
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance: ${totalBalance.toStringAsFixed(0)}/-',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Arial',
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: _showAddCardDialog,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCardDialog() async {
    final result = await showDialog<CardModel>(
      context: context,
      builder: (context) => const AddCardDialog(),
    );

    if (result != null) {
      setState(() {
        cards.add(result);
      });
    }
  }

  Future<void> _showTransactionDialog(CardModel card) async {
    await showDialog(
      context: context,
      builder: (context) => TransactionDialog(card: card),
    );
    _loadCards();
  }
}
