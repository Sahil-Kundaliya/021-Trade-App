import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../add_funds/presentation/bloc/account_funds_bloc.dart';
import '../../../add_funds/presentation/bloc/account_funds_event.dart';
import '../widgets/account_funds_content.dart';

class AccountFundsScreen extends StatelessWidget {
  const AccountFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<AccountFundsBloc>()..add(const AccountFundsStarted()),
      child: const AccountFundsContent(),
    );
  }
}
