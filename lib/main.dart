import 'package:core_data/core_data.dart';
import 'package:flutter/material.dart';
import 'package:zero_two_one_trade_assignment/app/app.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt<LocalNotificationService>().initialize();
  await getIt<TradingNotificationCoordinator>().start();
  await getIt<OrderExecutionEngine>().start();
  runApp(TradingApp());
}
