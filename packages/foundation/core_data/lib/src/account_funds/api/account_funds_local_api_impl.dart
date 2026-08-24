import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../cache/key_value_storage.dart';
import '../demo/demo_linked_banks.dart';
import '../exceptions/account_funds_exception.dart';
import '../models/account_funds_storage_dto.dart';
import '../models/linked_bank_account_dto.dart';
import '../models/local_fund_deposit_dto.dart';
import 'account_funds_local_api.dart';

@LazySingleton(as: AccountFundsLocalApi)
final class AccountFundsLocalApiImpl implements AccountFundsLocalApi {
  AccountFundsLocalApiImpl(this._storage)
    : _requestDelay = const Duration(milliseconds: 800);

  AccountFundsLocalApiImpl.forTests(
    this._storage, {
    this._requestDelay = Duration.zero,
  });

  static const storageKey = 'trading_account_funds_v1';
  static const maxAddPaise = 1000000;

  final KeyValueStorage _storage;
  final Duration _requestDelay;
  var _mutating = false;

  @override
  List<LinkedBankAccountDto> get linkedBanks => DemoLinkedBanks.all;

  @override
  Future<AccountFundsStorageDto> read() async {
    await Future<void>.delayed(_requestDelay);
    return _readStored();
  }

  @override
  Future<AccountFundsStorageDto> addFunds({
    required String depositId,
    required double amount,
    required String bankId,
  }) async {
    if (_mutating) {
      throw const AccountFundsException('Add funds is already in progress.');
    }
    _mutating = true;
    try {
      await Future<void>.delayed(_requestDelay);
      return _credit(depositId: depositId, amount: amount, bankId: bankId);
    } finally {
      _mutating = false;
    }
  }

  Future<AccountFundsStorageDto> _credit({
    required String depositId,
    required double amount,
    required String bankId,
  }) async {
    try {
      final id = depositId.trim();
      if (id.isEmpty) {
        throw const AccountFundsException('Deposit ID is required.');
      }
      final amountPaise = _toPaise(amount);
      if (amountPaise <= 0) {
        throw const AccountFundsException('Enter an amount greater than ₹0.');
      }
      if (amountPaise > maxAddPaise) {
        throw const AccountFundsException(
          'You can add a maximum of ₹10,000 at a time.',
        );
      }
      if (!linkedBanks.any((bank) => bank.id == bankId)) {
        throw const AccountFundsException('Select a linked bank account.');
      }

      final current = await _readStored();
      if (current.deposits.any((deposit) => deposit.id == id)) {
        throw const AccountFundsException('Deposit ID must be unique.');
      }

      final credited = AccountFundsStorageDto(
        availableBalance: _toRupees(
          _toPaise(current.availableBalance) + amountPaise,
        ),
        deposits: List<LocalFundDepositDto>.unmodifiable([
          ...current.deposits,
          LocalFundDepositDto(
            id: id,
            amount: _toRupees(amountPaise),
            bankId: bankId,
            createdAt: DateTime.now(),
          ),
        ]),
      );
      await _storage.setString(storageKey, jsonEncode(credited.toJson()));
      return credited;
    } on AccountFundsException {
      rethrow;
    } on Object catch (error) {
      throw AccountFundsException('Unable to add funds.', error);
    }
  }

  Future<AccountFundsStorageDto> _readStored() async {
    try {
      final source = await _storage.getString(storageKey);
      if (source == null || source.trim().isEmpty) {
        return AccountFundsStorageDto.empty();
      }
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid account funds document.');
      }
      return AccountFundsStorageDto.fromJson(decoded);
    } on AccountFundsException {
      rethrow;
    } on Object catch (error) {
      throw AccountFundsException('Unable to read account funds.', error);
    }
  }

  static int _toPaise(double rupees) {
    final normalized = double.parse(rupees.toStringAsFixed(2));
    if (normalized == 0) return 0;
    return (normalized * 100).round();
  }

  static double _toRupees(int paise) => paise / 100;
}
