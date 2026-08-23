import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../fund_search/presentation/bloc/search_bloc.dart';
import '../../../fund_search/presentation/bloc/search_event.dart';
import '../widgets/search_content.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({required this.navigator, super.key});

  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<SearchBloc>()..add(const SearchStarted()),
    child: SearchContent(navigator: navigator),
  );
}
