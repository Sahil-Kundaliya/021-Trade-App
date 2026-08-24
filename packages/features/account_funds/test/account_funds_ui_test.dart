import 'package:account_funds/src/add_funds/domain/entities/account_funds_data.dart';
import 'package:account_funds/src/add_funds/domain/entities/linked_bank_account.dart';
import 'package:account_funds/src/add_funds/domain/entities/trading_cash_balance.dart';
import 'package:account_funds/src/add_funds/domain/repositories/account_funds_repository.dart';
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_bloc.dart';
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_event.dart';
import 'package:account_funds/src/root/presentation/widgets/account_funds_content.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows available funds, banks, and a valid add CTA', (
    tester,
  ) async {
    await _pump(tester, _Repository());

    expect(find.text('Add Funds'), findsOneWidget);
    expect(find.text('Available Funds'), findsOneWidget);
    expect(find.text('₹0.00'), findsOneWidget);
    expect(find.text('HDFC Bank'), findsOneWidget);
    expect(find.textContaining('4321'), findsOneWidget);
    expect(find.text('PRIMARY'), findsOneWidget);
    expect(find.text('ICICI Bank'), findsOneWidget);
    expect(find.text('Add New Bank Account'), findsOneWidget);
    expect(find.text('ADD FUNDS'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('+₹5,000.00'));
    await tester.pump();

    expect(find.text('ADD ₹5,000.00'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'privacy mode masks available funds but keeps the amount usable',
    (tester) async {
      await _pump(tester, _Repository(), privacyMode: true);

      expect(find.text('Available Funds'), findsOneWidget);
      expect(find.text(PrivacyMask.currency), findsOneWidget);
      expect(find.text('₹0.00'), findsNothing);
      expect(find.textContaining('4321'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '500');
      await tester.pump();
      expect(find.text('500'), findsOneWidget);
      expect(find.text('ADD ₹500.00'), findsOneWidget);
    },
  );

  testWidgets('add bank sheet is view-only and does not link a bank', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);

    await tester.ensureVisible(find.text('Add New Bank Account'));
    await tester.tap(find.text('Add New Bank Account'));
    await tester.pumpAndSettle();

    expect(find.text('ADD BANK ACCOUNT'), findsOneWidget);
    expect(find.text('Demo only'), findsOneWidget);
    expect(
      find.text(
        'Bank account linking is not available in this local trading demo.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    expect(find.text('ADD BANK ACCOUNT'), findsNothing);
    expect(find.text('HDFC Bank'), findsOneWidget);
    expect(find.text('SBI Bank'), findsNothing);
    expect(repository.banks.length, 2);
  });

  testWidgets('successful add updates the balance and shows feedback', (
    tester,
  ) async {
    await _pump(tester, _Repository());

    await tester.tap(find.text('+₹5,000.00'));
    await tester.pump();
    await tester.tap(find.text('ADD ₹5,000.00'));
    await tester.pumpAndSettle();

    expect(find.text('₹5,000.00'), findsOneWidget);
    expect(find.text('Funds added successfully.'), findsOneWidget);
    expect(find.text('ADD FUNDS'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  bool privacyMode = false,
}) async {
  final bloc = AccountFundsBloc(repository)..add(const AccountFundsStarted());
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: PrivacyModeScope(
        enabled: privacyMode,
        child: BlocProvider.value(
          value: bloc,
          child: const AccountFundsContent(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _Repository implements AccountFundsRepository {
  var balance = 0.0;
  final banks = const [
    LinkedBankAccount(
      id: 'bank_hdfc_demo',
      bankName: 'HDFC Bank',
      last4: '4321',
      accountType: BankAccountType.savings,
      isPrimary: true,
    ),
    LinkedBankAccount(
      id: 'bank_icici_demo',
      bankName: 'ICICI Bank',
      last4: '9854',
      accountType: BankAccountType.savings,
      isPrimary: false,
    ),
  ];

  @override
  Future<AccountFundsData> getAccountFunds() async => AccountFundsData(
    balance: TradingCashBalance(available: balance),
    banks: banks,
    deposits: const [],
  );

  @override
  Future<AccountFundsData> addFunds({
    required double amount,
    required String bankId,
  }) async {
    balance += amount;
    return getAccountFunds();
  }
}
