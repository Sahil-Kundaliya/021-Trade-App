import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../fund_details/presentation/bloc/fund_details_bloc.dart';
import '../../../fund_details/presentation/bloc/fund_details_event.dart';
import '../../../fund_details/presentation/bloc/fund_details_state.dart';
import '../../../fund_details/presentation/widgets/fund_sections.dart';

class FundContent extends StatelessWidget {
  const FundContent({
    required this.onBuy,
    required this.onSell,
    this.scrollController,
    this.onClose,
    this.showDragHandle = false,
    super.key,
  });
  final VoidCallback onBuy;
  final VoidCallback onSell;
  final ScrollController? scrollController;
  final VoidCallback? onClose;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FundDetailsBloc, FundDetailsState>(
        listenWhen: (previous, current) =>
            previous.messageVersion != current.messageVersion &&
            current.message != null,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!))),
        builder: (context, state) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (showDragHandle) ...[
              Center(
                child: Container(
                  width: AppSizes.buttonHeightSm,
                  height: AppRadius.xs,
                  decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: AppRadius.pillBorderRadius,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close fund details',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ),
            switch (state.status) {
              FundDetailsStatus.initial ||
              FundDetailsStatus.loading => const SizedBox(
                height: 360,
                child: Center(child: CircularProgressIndicator()),
              ),
              FundDetailsStatus.error => AppEmptyState(
                title: 'Unable to load fund details',
                description: state.errorMessage ?? 'Please try again.',
                action: AppButton(
                  label: 'Retry',
                  onPressed: () => context.read<FundDetailsBloc>().add(
                    const FundDetailsRetryRequested(),
                  ),
                ),
              ),
              FundDetailsStatus.loaded => FundLoadedSections(
                state: state,
                onBuy: onBuy,
                onSell: onSell,
              ),
            },
          ],
        ),
      );
}
