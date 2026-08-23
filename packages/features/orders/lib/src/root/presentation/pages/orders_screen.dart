import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../../order_placement/presentation/bloc/order_placement_bloc.dart';
import '../../../order_placement/presentation/bloc/order_placement_event.dart';
import '../widgets/orders_content.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    required this.fundId,
    required this.navigator,
    this.side,
    super.key,
  });
  final String fundId;
  final TradeSide? side;
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<OrderPlacementBloc>()
          ..add(OrderPlacementStarted(fundId: fundId, side: side)),
    child: OrdersContent(navigator: navigator),
  );
}
