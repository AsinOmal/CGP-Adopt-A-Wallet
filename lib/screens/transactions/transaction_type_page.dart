import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/components/transaction_type_tile.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/screens/transactions/add_expense_page.dart';
import 'package:financial_app/screens/transactions/add_income_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth/auth_repository.dart';

class TransactionTypePage extends StatefulWidget {
  const TransactionTypePage({super.key});

  @override
  State<TransactionTypePage> createState() => _TransactionTypePageState();
}

class _TransactionTypePageState extends State<TransactionTypePage> {
  String _selectedType = 'Expense';
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 35),
          ),
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              _transactionBloc
                  .add(TransactionFetchEvent(userID: _authRepository.userID));
            },
            icon: const Icon(Icons.arrow_back)),
        title:  Center(
          child: Text(
            AppLocalizations.of(context).translate('transaction'),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
             AppLocalizations.of(context).translate('select_your_transaction_type'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            TransactionTypeTile(
              icon: Icons.book,
              title: 'Expense',
              isSelected: _selectedType == 'Expense',
              onTap: () {
                setState(() {
                  _selectedType = 'Expense';
                });
              },
            ),
            TransactionTypeTile(
              icon: Icons.auto_graph,
              title: 'Income',
              isSelected: _selectedType == 'Income',
              onTap: () {
                setState(() {
                  _selectedType = 'Income';
                });
              },
            ),
            const Spacer(),
            SimpleButton(
              data: 'Next',
              onPressed: () {
                if (_selectedType == 'Expense') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpensePage(),
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddIncomePage(),
                      ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
