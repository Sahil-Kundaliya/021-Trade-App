import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_bloc.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';

typedef ConnectivityChildBuilder = Widget Function(Key recoveryKey);

/// Replaces only an Internet-required route's presentation while retaining the
/// route itself. A reconnect rebuilds that active route once, invoking its
/// existing initial-load contract without touching other feature BLoCs.
class ConnectivityGuard extends StatefulWidget {
  const ConnectivityGuard({required this.childBuilder, super.key});

  final ConnectivityChildBuilder childBuilder;

  @override
  State<ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends State<ConnectivityGuard> {
  int _recoveryGeneration = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) => previous.isOffline && current.isOnline,
      listener: (context, state) {
        final route = ModalRoute.of(context);
        if (!TickerMode.valuesOf(context).enabled ||
            (route != null && !route.isCurrent)) {
          return;
        }
        setState(() => _recoveryGeneration++);
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.hasCheckedInitially != current.hasCheckedInitially,
      builder: (context, state) {
        final content = widget.childBuilder(ValueKey<int>(_recoveryGeneration));
        if (!state.hasCheckedInitially || !state.isOffline) return content;
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(offstage: true, child: content),
            ColoredBox(
              color: context.appColors.background,
              child: SafeArea(
                child: AppOfflineState(
                  onRetry: () => context.read<ConnectivityBloc>().add(
                    const ConnectivityRecheckRequested(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
