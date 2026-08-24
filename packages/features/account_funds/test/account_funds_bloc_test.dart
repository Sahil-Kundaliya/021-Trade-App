import 'package:account_funds/src/add_funds/domain/account_funds_money.dart';
import 'package:account_funds/src/add_funds/domain/entities/account_funds_data.dart';
import 'package:account_funds/src/add_funds/domain/entities/linked_bank_account.dart';
import 'package:account_funds/src/add_funds/domain/entities/trading_cash_balance.dart';
import 'package:account_funds/src/add_funds/domain/repositories/account_funds_repository.dart';
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_bloc.dart';
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_event.dart';
import 'package:account_funds/src/add_funds/presentation/bloc/account_funds_state.dart';
import 'package:account_funds/src/add_funds/presentation/formatters/account_funds_amount_formatter.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads a zero balance and selects the primary bank', () async {
    final bloc = AccountFundsBloc(_Repository())
      ..add(const AccountFundsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AccountFundsStatus.loaded,
    );

    expect(bloc.state.availableBalance, 0);
    expect(bloc.state.selectedBankId, 'bank_hdfc_demo');
    expect(bloc.state.canSubmit, isFalse);
    await bloc.close();
  });

  test('quick amounts set rather than accumulate and enable the CTA', () async {
    final bloc = AccountFundsBloc(_Repository())
      ..add(const AccountFundsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AccountFundsStatus.loaded,
    );

    bloc.add(const AccountFundsQuickAmountSelected(1000));
    await bloc.stream.firstWhere((state) => state.enteredAmount == '1000.00');
    bloc.add(const AccountFundsQuickAmountSelected(5000));
    await bloc.stream.firstWhere((state) => state.enteredAmount == '5000.00');

    expect(bloc.state.parsedAmount, 5000);
    expect(bloc.state.canSubmit, isTrue);
    expect(bloc.state.validationMessage, isNull);
    await bloc.close();
  });

  test('rejects zero and amounts above ₹10,000 without submitting', () async {
    final repository = _Repository();
    final bloc = AccountFundsBloc(repository)..add(const AccountFundsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AccountFundsStatus.loaded,
    );

    bloc.add(const AccountFundsAmountChanged('0'));
    await bloc.stream.firstWhere(
      (state) =>
          state.validationMessage == AccountFundsMoney.greaterThanZeroMessage,
    );
    expect(bloc.state.canSubmit, isFalse);

    bloc.add(const AccountFundsAmountChanged('10000'));
    await bloc.stream.firstWhere((state) => state.canSubmit);
    expect(bloc.state.validationMessage, isNull);

    bloc.add(const AccountFundsAmountChanged('10000.01'));
    await bloc.stream.firstWhere(
      (state) => state.validationMessage == AccountFundsMoney.maxPerAddMessage,
    );
    expect(bloc.state.canSubmit, isFalse);

    bloc.add(const AccountFundsAddRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repository.addCalls, 0);
    await bloc.close();
  });

  test(
    'successful add updates balance, clears amount, and keeps the bank',
    () async {
      final repository = _Repository();
      final bloc = AccountFundsBloc(repository)
        ..add(const AccountFundsStarted());
      await bloc.stream.firstWhere(
        (state) => state.status == AccountFundsStatus.loaded,
      );

      bloc.add(const AccountFundsQuickAmountSelected(5000));
      await bloc.stream.firstWhere((state) => state.canSubmit);
      bloc.add(const AccountFundsBankSelected('bank_icici_demo'));
      await bloc.stream.firstWhere(
        (state) => state.selectedBankId == 'bank_icici_demo',
      );
      bloc.add(const AccountFundsAddRequested());
      await bloc.stream.firstWhere(
        (state) => state.successMessage == AccountFundsMoney.addSuccessMessage,
      );

      expect(bloc.state.availableBalance, 5000);
      expect(bloc.state.enteredAmount, isEmpty);
      expect(bloc.state.selectedBankId, 'bank_icici_demo');
      expect(repository.lastBankId, 'bank_icici_demo');
      expect(repository.addCalls, 1);

      bloc.add(const AccountFundsQuickAmountSelected(7500));
      await bloc.stream.firstWhere((state) => state.canSubmit);
      bloc.add(const AccountFundsAddRequested());
      await bloc.stream.firstWhere((state) => state.availableBalance == 12500);
      expect(repository.addCalls, 2);
      await bloc.close();
    },
  );

  test('failed add keeps the entered amount and previous balance', () async {
    final repository = _Repository()..failNextAdd = true;
    final bloc = AccountFundsBloc(repository)..add(const AccountFundsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AccountFundsStatus.loaded,
    );

    bloc.add(const AccountFundsQuickAmountSelected(2500));
    await bloc.stream.firstWhere((state) => state.canSubmit);
    bloc.add(const AccountFundsAddRequested());
    await bloc.stream.firstWhere(
      (state) => state.addError == AccountFundsMoney.addFailureMessage,
    );

    expect(bloc.state.availableBalance, 0);
    expect(bloc.state.enteredAmount, '2500.00');
    expect(bloc.state.selectedBankId, 'bank_hdfc_demo');
    expect(bloc.state.isAdding, isFalse);
    await bloc.close();
  });

  test('ignores a second add while the first is in flight', () async {
    final repository = _Repository(addDelay: const Duration(milliseconds: 40));
    final bloc = AccountFundsBloc(repository)..add(const AccountFundsStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == AccountFundsStatus.loaded,
    );

    bloc.add(const AccountFundsQuickAmountSelected(5000));
    await bloc.stream.firstWhere((state) => state.canSubmit);
    bloc.add(const AccountFundsAddRequested());
    bloc.add(const AccountFundsAddRequested());
    await bloc.stream.firstWhere((state) => state.availableBalance == 5000);
    await Future<void>.delayed(Duration.zero);

    expect(repository.addCalls, 1);
    await bloc.close();
  });

  test('amount formatter rejects letters, extra decimals, and negatives', () {
    const formatter = AccountFundsAmountFormatter();
    TextEditingValue edit(String from, String to) => formatter.formatEditUpdate(
      TextEditingValue(text: from),
      TextEditingValue(text: to),
    );

    expect(edit('', '5000').text, '5000');
    expect(edit('500', '500.5').text, '500.5');
    expect(edit('500.5', '500.50').text, '500.50');
    expect(edit('500.50', '500.999').text, '500.50');
    expect(edit('500', '500a').text, '500');
    expect(edit('500', '500.50.1').text, '500');
    expect(edit('', '-1').text, '');
  });
}

class _Repository implements AccountFundsRepository {
  _Repository({this.addDelay});

  final Duration? addDelay;
  var balance = 0.0;
  var addCalls = 0;
  var failNextAdd = false;
  String? lastBankId;

  @override
  Future<AccountFundsData> getAccountFunds() async => _data();

  @override
  Future<AccountFundsData> addFunds({
    required double amount,
    required String bankId,
  }) async {
    addCalls++;
    lastBankId = bankId;
    final delay = addDelay;
    if (delay != null) await Future<void>.delayed(delay);
    if (failNextAdd) {
      failNextAdd = false;
      throw const AccountFundsException('Unable to add funds.');
    }
    balance += amount;
    return _data();
  }

  AccountFundsData _data() => AccountFundsData(
    balance: TradingCashBalance(available: balance),
    banks: const [
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
    ],
    deposits: const [],
  );
}
