import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_bloc.dart';
import 'connectivity_event.dart';

class AppConnectivityLifecycle extends StatefulWidget {
  const AppConnectivityLifecycle({required this.child, super.key});

  final Widget child;

  @override
  State<AppConnectivityLifecycle> createState() =>
      _AppConnectivityLifecycleState();
}

class _AppConnectivityLifecycleState extends State<AppConnectivityLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ConnectivityBloc>().add(const ConnectivityAppResumed());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
