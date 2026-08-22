import 'package:flutter/material.dart';
import 'package:zero_two_one_trade_assignment/app/app.dart';
import 'package:zero_two_one_trade_assignment/app/dependency_injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(TradingApp());
}
