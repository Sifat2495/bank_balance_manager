import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({super.key});

  @override
  _AddCardDialogState createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedCardType = 'Credit Card';
  String _selectedLogo = '';

  final Map<String, String> _bankLogos = {
    'Dutch-Bangla Bank Limited': 'assets/dbbll.png',
    'Sonali Bank Limited': 'assets/sonali.png',
    'BRAC Bank Limited': 'assets/brac.jpg',
    'National Bank Limited': 'assets/nbl.png',
    'Islami Bank Bangladesh Limited': 'assets/islami.png',
    'Eastern Bank Limited': 'assets/eastern.png',
    'Prime Bank Limited': 'assets/prime.png',
    'United Commercial Bank Limited': 'assets/ucb.png',
    'Standard Chartered Bank': 'assets/standard.png',


    'Mutual Trust Bank': 'assets/mtb.png',

    'First Security Islami Bank Limited': 'assets/fsib.png',
    'bKash': 'assets/Bkash.png',
    'Rocket': 'assets/rocket.png',
    'Nagad': 'assets/nagad.png',





  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Card'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _bankLogos.keys.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _nameController.text = selection;
                _selectedLogo = _bankLogos[selection]!;
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Card Name'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a name' : null,
                );
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCardType,
              items: ['Credit Card', 'Debit Card', 'Mobile Banking', 'A/C']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCardType = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Card Type'),
            ),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(labelText: 'Initial Balance'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter a balance';
                final balance = double.tryParse(value!);
                if (balance == null) return 'Please enter a valid number';
                if (balance < 0) return 'Balance cannot be negative';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveCard,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newCard = CardModel(
          name: _nameController.text,
          type: _selectedCardType,
          balance: double.parse(_balanceController.text),
          logo: _selectedLogo,
        );


        final savedCard = await DatabaseHelper.instance.insertCard(newCard);


        if (savedCard.balance > 0) {
          await DatabaseHelper.instance.recordTransaction(
            savedCard.id!,
            'Initial deposit',
            savedCard.balance,
            savedCard.balance,
          );
        }


        Navigator.pop(context, savedCard);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add card')),
        );
      }
    }
  }
}