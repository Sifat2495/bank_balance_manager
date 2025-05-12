import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';

class TransactionDialog extends StatefulWidget {
  final CardModel card;

  const TransactionDialog({required this.card, super.key});

  @override
  _TransactionDialogState createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  double? amount;
  String transactionType = 'Deposit';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transaction for ${widget.card.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: transactionType,
            items: ['Deposit', 'Withdraw']
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                transactionType = value!;
              });
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              amount = double.tryParse(value);
            },
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter an amount';
              final amount = double.tryParse(value!);
              if (amount == null) return 'Please enter a valid number';
              if (amount <= 0) return 'Amount must be greater than zero';
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (amount != null && amount! > 0) {
              try {
                final newBalance = transactionType == 'Deposit'
                    ? widget.card.balance + amount!
                    : widget.card.balance - amount!;

                if (transactionType == 'Withdraw' && amount! > widget.card.balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insufficient balance')),
                  );
                  return;
                }

                await DatabaseHelper.instance.updateCardBalance(widget.card.id!, newBalance);
                await DatabaseHelper.instance.recordTransaction(
                  widget.card.id!,
                  transactionType,
                  amount!,
                  newBalance,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${transactionType.toLowerCase()} successful')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to process transaction')),
                );
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
