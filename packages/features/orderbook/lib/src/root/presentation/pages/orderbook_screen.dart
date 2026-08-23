import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../orderbook/presentation/bloc/orderbook_bloc.dart';
import '../../../orderbook/presentation/bloc/orderbook_event.dart';
import '../widgets/orderbook_content.dart';

class OrderBookScreen extends StatelessWidget {
  const OrderBookScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<OrderBookBloc>()..add(const OrderBookStarted()),
    child: const OrderBookContent(),
  );
}
