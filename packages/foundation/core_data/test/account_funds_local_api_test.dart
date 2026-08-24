import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AccountFundsLocalApiImpl apiWith(_MemoryStorage storage) =>
      AccountFundsLocalApiImpl.forTests(storage);

  test(
    'missing storage starts at a zero demo balance without writing',
    () async {
      final storage = _MemoryStorage();
      final api = apiWith(storage);

      final snapshot = await api.read();
      expect(snapshot.availableBalance, 0);
      expect(snapshot.deposits, isEmpty);
      expect(storage.writeCount, 0);
    },
  );

  test('demo banks are static and only store masked last4 values', () {
    final api = apiWith(_MemoryStorage());
    expect(api.linkedBanks.map((bank) => bank.id), [
      'bank_hdfc_demo',
      'bank_icici_demo',
      'bank_axis_demo',
    ]);
    expect(api.linkedBanks.first.isPrimary, isTrue);
    for (final bank in api.linkedBanks) {
      expect(bank.last4.length, 4);
      expect(bank.last4.contains('•'), isFalse);
    }
  });

  test('successful adds persist balance and deposit history', () async {
    final storage = _MemoryStorage();
    final first = apiWith(storage);

    final afterFirst = await first.addFunds(
      depositId: 'deposit_a',
      amount: 5000,
      bankId: DemoLinkedBanks.hdfc.id,
    );
    expect(afterFirst.availableBalance, 5000);
    expect(afterFirst.deposits.single.bankId, DemoLinkedBanks.hdfc.id);

    final afterSecond = await apiWith(storage).addFunds(
      depositId: 'deposit_b',
      amount: 7500,
      bankId: DemoLinkedBanks.icici.id,
    );
    expect(afterSecond.availableBalance, 12500);
    expect(afterSecond.deposits.map((deposit) => deposit.id), [
      'deposit_a',
      'deposit_b',
    ]);
    expect(afterSecond.deposits.last.bankId, DemoLinkedBanks.icici.id);

    final restored = await apiWith(storage).read();
    expect(restored.availableBalance, 12500);
    expect(restored.deposits.length, 2);
  });

  test('₹10,000 is valid per add and does not cap total balance', () async {
    final api = apiWith(_MemoryStorage());
    await api.addFunds(
      depositId: 'deposit_max',
      amount: 10000,
      bankId: DemoLinkedBanks.hdfc.id,
    );
    final next = await api.addFunds(
      depositId: 'deposit_over_total',
      amount: 10000,
      bankId: DemoLinkedBanks.axis.id,
    );
    expect(next.availableBalance, 20000);
  });

  test('rejects amounts above ₹10,000 without changing storage', () async {
    final storage = _MemoryStorage();
    final api = apiWith(storage);
    await api.addFunds(
      depositId: 'deposit_ok',
      amount: 5000,
      bankId: DemoLinkedBanks.hdfc.id,
    );

    expect(
      () => api.addFunds(
        depositId: 'deposit_too_big',
        amount: 10000.01,
        bankId: DemoLinkedBanks.hdfc.id,
      ),
      throwsA(isA<AccountFundsException>()),
    );
    expect((await api.read()).availableBalance, 5000);
    expect((await api.read()).deposits, hasLength(1));
  });

  test('rejects zero and unknown banks', () async {
    final api = apiWith(_MemoryStorage());
    expect(
      () => api.addFunds(
        depositId: 'deposit_zero',
        amount: 0,
        bankId: DemoLinkedBanks.hdfc.id,
      ),
      throwsA(isA<AccountFundsException>()),
    );
    expect(
      () => api.addFunds(
        depositId: 'deposit_bank',
        amount: 500,
        bankId: 'bank_unknown',
      ),
      throwsA(isA<AccountFundsException>()),
    );
  });

  test('uses a single storage key', () {
    expect(AccountFundsLocalApiImpl.storageKey, 'trading_account_funds_v1');
  });
}

final class _MemoryStorage implements KeyValueStorage {
  String? value;
  int writeCount = 0;

  @override
  Future<String?> getString(String key) async => value;
  @override
  Future<void> setString(String key, String value) async {
    this.value = value;
    writeCount++;
  }

  @override
  Future<void> clear() async => value = null;
  @override
  Future<void> remove(String key) async => value = null;
}
