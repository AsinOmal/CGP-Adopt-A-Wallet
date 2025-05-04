import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/transaction_tile.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/transactions/transaction_type_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc.add(TransactionFetchEvent(userID: _authRepository.userID));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('all_transactions'),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionTypePage(),
              ));
        },
        backgroundColor: const Color(0xFF456EFE),
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: LiquidPullToRefresh(
        color: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onRefresh: () async {
          _transactionBloc
              .add(TransactionFetchEvent(userID: _authRepository.userID));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BlocBuilder<TransactionBloc, TransactionState>(
            bloc: _transactionBloc,
            buildWhen: (previous, current) {
              return current is TransactionFetchLoading ||
                  current is TransactionLoaded ||
                  current is TransactionError ||
                  current is TransactionEmpty;
            },
            builder: (context, state) {
              if (state is TransactionFetchLoading) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              } else if (state is TransactionLoaded) {
                return ListView.builder(
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                      deleteFunction: (p0) {
                        _transactionBloc.add(
                          TransactionDeleteEvent(
                            transactionID: transaction.id,
                          ),
                        );
                        _transactionBloc.add(TransactionFetchEvent(
                            userID: _authRepository.userID));
                        showSuccessSnakBar();
                      },
                    );
                  },
                );
              } else if (state is TransactionEmpty) {
                return Center(
                    child: Text(
                  AppLocalizations.of(context)
                      .translate('no_transactions_found'),
                ));
              }
              return Center(
                  child: Text(
                AppLocalizations.of(context).translate('no_transactions_found'),
              ));
            },
          ),
        ),
      ),
    );
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: 'Deleted!!',
      message: 'Your transaction has been deleted successfully.',
      contentType: ContentType.success,
    );
  }
}
