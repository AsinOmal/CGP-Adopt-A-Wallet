import 'package:financial_app/blocs/budget/budget_bloc.dart';
import 'package:financial_app/components/budget_card.dart';
import 'package:financial_app/components/balance_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'budget_add.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late AuthRepository _authRepository;
  late BudgetBloc _budgetBloc;

  @override
  void initState() {
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _budgetBloc = RepositoryProvider.of<BudgetBloc>(context);
    _budgetBloc.add(BudgetFetchEvent(userID: _authRepository.userID));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 30),
          ),
        ],
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('your_budgets'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const BalanaceCard(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('create_a_budget'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('save_more_by_setting_budget'),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceDim,
                        ),
                        padding:
                            const WidgetStatePropertyAll(EdgeInsets.all(13))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetAdd(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).translate('my_budgets'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BudgetBloc, BudgetState>(
                bloc: _budgetBloc,
                buildWhen: (previous, current) {
                  return current is BudgetFetchError ||
                      current is BudgetFetchLoading ||
                      current is BudgetFetchLoaded ||
                      current is BudgetsEmpty;
                },
                builder: (context, state) {
                  if (state is BudgetFetchLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  } else if (state is BudgetFetchLoaded) {
                    return ListView.builder(
                      itemCount: state.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = state.budgets[index];
                        return BudgetCard(
                          budget: budget,
                          deleteFunction: (context) {
                            _budgetBloc
                                .add(BudgetDeleteEvent(budgetID: budget.id));

                            _budgetBloc.add(BudgetFetchEvent(
                                userID: _authRepository.userID));
                          },
                        );
                      },
                    );
                  } else if (state is BudgetsEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('create_budgets_info'),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Center(
                      child: Text(
                    AppLocalizations.of(context).translate('no_budgets_found'),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
