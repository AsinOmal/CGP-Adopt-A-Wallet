import 'package:financial_app/blocs/goal/goal_bloc.dart';
import 'package:financial_app/components/goal_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/goals/add_goal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  late GoalBloc _goalBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _goalBloc = RepositoryProvider.of<GoalBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _goalBloc.add(GoalFetchEvent(userID: _authRepository.userID));
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
            AppLocalizations.of(context).translate('your_goals'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGoalPage(),
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
          _goalBloc.add(GoalFetchEvent(userID: _authRepository.userID));
        },
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: BlocBuilder<GoalBloc, GoalState>(
            bloc: _goalBloc,
            buildWhen: (previous, current) {
              return current is GoalFetchLoading ||
                  current is GoalsEmpty ||
                  current is GoalLoaded;
            },
            builder: (context, state) {
              if (state is GoalFetchLoading) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              } else if (state is GoalLoaded) {
                return ListView.builder(
                  itemCount: state.goals.length,
                  itemBuilder: (context, index) {
                    final goal = state.goals[index];
                    return GoalCard(
                      id: goal.id,
                      title: goal.title,
                      deadline: goal.deadline,
                      currentAmount: goal.currentAmount,
                      targetAmount: goal.targetAmount,
                      createdAt: goal.createdAt,
                      deleteFunction: (p0) {
                        _goalBloc.add(GoalDeleteEvent(goalID: goal.id));
                        _goalBloc.add(
                            GoalFetchEvent(userID: _authRepository.userID));
                      },
                    );
                  },
                );
              } else if (state is GoalsEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)
                        .translate('task_no_goals_found')));
              }
              return Center(
                  child: Text(AppLocalizations.of(context)
                      .translate('task_no_goals_found')));
            },
          ),
        ),
      ),
    );
  }
}
