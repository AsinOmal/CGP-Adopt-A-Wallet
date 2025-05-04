import 'package:financial_app/blocs/card/card_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/visa-master-cards/card_widget.dart';
import 'package:financial_app/components/visa-master-cards/empty_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/cards/add_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final _controller = PageController();

  late CardBloc _cardBloc;
  late AuthRepository _authRepository;

  int itemCount = 1;
  @override
  void initState() {
    _cardBloc = RepositoryProvider.of<CardBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    super.initState();
    _cardBloc.add(CardFetchEvent(userID: _authRepository.userID));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('my_cards'),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
              height: 210,
              child: BlocBuilder<CardBloc, CardState>(
                buildWhen: (previous, current) {
                  return current is CardFetchLoading ||
                      current is CardFetchLoaded ||
                      current is CardDeleteLoading ||
                      current is CardDeleteSuccess ||
                      current is CardFetchEmpty;
                },
                builder: (context, state) {
                  if (state is CardFetchLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  } else if (state is CardFetchLoaded) {
                    return PageView.builder(
                      itemCount: state.cards.length,
                      controller: _controller,
                      itemBuilder: (context, index) {
                        final card = state.cards[index];
                        return CardWidget(
                          card: card,
                          deleteFunction: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Are you sure want to delete this card?',
                                  style: TextStyle(fontSize: 20),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _cardBloc.add(
                                          CardDeleteEvent(cardID: card.id));
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'No',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (state is CardDeleteLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  } else if (state is CardDeleteSuccess) {
                    _cardBloc
                        .add(CardFetchEvent(userID: _authRepository.userID));
                  } else if (state is CardDeleteError) {
                    CustomSnackBar.showErrorSnackBar(state.message, context);
                  } else if (state is CardFetchEmpty) {
                    return const EmptyCard();
                  }
                  return const EmptyCard();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<CardBloc, CardState>(
            builder: (context, state) {
              if (state is CardFetchLoaded) {
                return SmoothPageIndicator(
                  controller: _controller,
                  count: state.cards.length,
                  effect: SwapEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Theme.of(context).colorScheme.surfaceDim,
                    dotHeight: 10,
                  ),
                );
              }
              return SmoothPageIndicator(
                controller: _controller,
                count: 1,
                effect: SwapEffect(
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Theme.of(context).colorScheme.surfaceDim,
                  dotHeight: 10,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .translate('add_new_card'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              AppLocalizations.of(context)
                                  .translate('save_time_by_adding_cards'),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.surfaceDim,
                            ),
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.all(13))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCardPage(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
