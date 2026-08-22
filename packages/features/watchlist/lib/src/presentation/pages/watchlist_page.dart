import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../root/presentation/widgets/watchlist_content.dart';
import '../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../watchlist/presentation/bloc/watchlist_event.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({this.navigator, super.key});

  final AppNavigator? navigator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<WatchlistBloc>()..add(const WatchlistStarted()),
      child: WatchlistContent(navigator: navigator),
    );
  }
}
