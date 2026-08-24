import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enums/order_enums.dart';
import '../bloc/order_placement_bloc.dart';
import '../bloc/order_placement_event.dart';
import '../bloc/order_placement_state.dart';

class OrderFailure extends StatelessWidget {
  const OrderFailure({required this.state, required this.onDone, super.key});

  final OrderPlacementState state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isBuy = state.side == OrderSide.buy;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: context.motionDuration(AppMotion.standard),
                curve: AppMotionCurves.emphasized,
                tween: Tween(begin: 0.92, end: 1),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Icon(
                  Icons.cancel,
                  size: AppSizes.iconLg,
                  color: context.appColors.negative,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Order Failed', style: context.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.errorMessage ?? 'Unable to place order.',
                textAlign: TextAlign.center,
                style: context.appTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (isBuy)
                _BuyDetails(state: state)
              else
                _SellDetails(state: state),
              const SizedBox(height: AppSpacing.xl),
              if (isBuy) ...[
                AppButton(
                  label: 'Add Funds & Retry',
                  onPressed: () => showAddFundsAndRetrySheet(context, state),
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.sm),
              ] else if (state.availableSellQuantity > 0 &&
                  state.availableSellQuantity < state.quantity) ...[
                AppButton(
                  label: 'Sell Available (${state.availableSellQuantity})',
                  onPressed: () => context.read<OrderPlacementBloc>().add(
                    const OrderSellAvailableRequested(),
                  ),
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyDetails extends StatelessWidget {
  const _BuyDetails({required this.state});
  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        _DetailRow(label: 'Available Funds', value: state.availableFunds),
        const AppDivider(),
        _DetailRow(label: 'Order Value', value: state.estimatedOrderValue),
        _DetailRow(
          label: '3% LTP Buffer',
          value: state.instrument!.ltp * state.quantity * 0.03,
        ),
        const AppDivider(),
        _DetailRow(label: 'Funds Required', value: state.requiredFunds),
        _DetailRow(label: 'Amount to Add', value: state.fundShortfall),
      ],
    ),
  );
}

class _SellDetails extends StatelessWidget {
  const _SellDetails({required this.state});
  final OrderPlacementState state;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        _DetailRow(
          label: 'Available Quantity',
          textValue: '${state.availableSellQuantity}',
          type: SensitiveValueType.quantity,
        ),
        const AppDivider(),
        _DetailRow(
          label: 'Quantity Requested',
          textValue: '${state.quantity}',
          type: SensitiveValueType.quantity,
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.textValue,
    this.type = SensitiveValueType.currency,
  });

  final String label;
  final double? value;
  final String? textValue;
  final SensitiveValueType type;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: context.appTextStyles.bodySecondary),
        ),
        SensitiveValueText(
          textValue ?? FinancialFormatter.price(value!),
          type: type,
          style: context.appTextStyles.tableValue,
        ),
      ],
    ),
  );
}

Future<void> showAddFundsAndRetrySheet(
  BuildContext context,
  OrderPlacementState state,
) {
  final bloc = context.read<OrderPlacementBloc>();
  final suggestedAmount = (state.fundShortfall * 100).ceil() / 100;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _AddFundsAndRetrySheet(suggestedAmount: suggestedAmount),
    ),
  );
}

class _AddFundsAndRetrySheet extends StatefulWidget {
  const _AddFundsAndRetrySheet({required this.suggestedAmount});
  final double suggestedAmount;

  @override
  State<_AddFundsAndRetrySheet> createState() => _AddFundsAndRetrySheetState();
}

class _AddFundsAndRetrySheetState extends State<_AddFundsAndRetrySheet> {
  late final TextEditingController _controller;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.suggestedAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _validationMessage = 'Enter an amount greater than ₹0.';
      });
      return;
    }
    setState(() => _validationMessage = null);
    context.read<OrderPlacementBloc>().add(
      OrderFundsAddedAndRetryRequested(amount),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<OrderPlacementBloc, OrderPlacementState>(
    listenWhen: (previous, current) =>
        previous.status == OrderPlacementStatus.failed &&
        current.status != OrderPlacementStatus.failed,
    listener: (context, state) => Navigator.of(context).pop(),
    builder: (context, state) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Funds & Retry', style: context.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.suggestedAmount > 10000
                  ? 'The total includes the 3% LTP buffer and will be added in ₹10,000-or-less parts.'
                  : 'The suggested amount includes the 3% LTP buffer.',
              style: context.appTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _controller,
              label: 'Amount',
              prefixIcon: const Icon(Icons.currency_rupee),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              errorText: _validationMessage ?? state.addFundsError,
              enabled: !state.isAddingFunds,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: state.isAddingFunds ? 'Adding Funds...' : 'Add & Retry',
              onPressed: state.isAddingFunds ? null : _submit,
              expand: true,
            ),
          ],
        ),
      ),
    ),
  );
}
