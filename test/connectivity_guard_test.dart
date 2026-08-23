import 'package:core_data/core_data.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_event.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_guard.dart';

void main() {
  testWidgets(
    'shows offline state and rebuilds only guarded content on recovery',
    (tester) async {
      final service = _GuardConnectivityService();
      final bloc = ConnectivityBloc(service)..add(const ConnectivityStarted());
      final recoveryKeys = <Key>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            theme: AppTheme.light,
            home: ConnectivityGuard(
              childBuilder: (key) {
                recoveryKeys.add(key);
                return SizedBox(key: key, child: const Text('Feature content'));
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppOfflineState), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(service.checkCount, 2);

      bloc.add(const ConnectivityStatusChanged(ConnectivityStatus.online));
      await tester.pumpAndSettle();
      expect(find.text('Feature content'), findsOneWidget);
      expect(recoveryKeys.toSet(), {
        const ValueKey<int>(0),
        const ValueKey<int>(1),
      });

      bloc.add(const ConnectivityStatusChanged(ConnectivityStatus.online));
      await tester.pump();
      expect(recoveryKeys.toSet(), hasLength(2));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

final class _GuardConnectivityService implements ConnectivityService {
  int checkCount = 0;

  @override
  Stream<ConnectivityStatus> get statusStream => const Stream.empty();

  @override
  Future<ConnectivityStatus> checkNow() async {
    checkCount++;
    return ConnectivityStatus.offline;
  }

  @override
  Future<void> dispose() async {}
}
