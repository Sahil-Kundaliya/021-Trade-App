import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fund/src/fund_details/domain/entities/option_chain.dart';

void main() {
  OptionContract contract({
    required String id,
    required DateTime expiry,
    required int strike,
    required OptionSide side,
    int ltp = 2000,
  }) => OptionContract(
    fundId: id,
    exchange: TradeExchange.nse,
    marketKey: '$id:NSE',
    symbol: id,
    underlyingSymbol: 'RELIANCE',
    expiry: expiry,
    strikeMinor: strike,
    side: side,
    ltpMinor: ltp,
    previousCloseMinor: 1800,
    tickSizeMinor: 5,
    lotSize: 500,
  );

  final expiryA = DateTime(2026, 8, 25);
  final expiryB = DateTime(2026, 9, 29);

  test('expiry filter keeps only the selected date', () {
    final rows = OptionChainAssembler.rows(
      contracts: [
        contract(id: 'A_CE', expiry: expiryA, strike: 130000, side: OptionSide.call),
        contract(id: 'B_CE', expiry: expiryB, strike: 130000, side: OptionSide.call),
      ],
      expiry: expiryA,
    );
    expect(rows, hasLength(1));
    expect(rows.single.call?.fundId, 'A_CE');
  });

  test('pairs CE and PE on the same strike', () {
    final rows = OptionChainAssembler.rows(
      contracts: [
        contract(id: 'CE', expiry: expiryA, strike: 130000, side: OptionSide.call),
        contract(id: 'PE', expiry: expiryA, strike: 130000, side: OptionSide.put),
      ],
      expiry: expiryA,
    );
    expect(rows, hasLength(1));
    expect(rows.single.call?.fundId, 'CE');
    expect(rows.single.put?.fundId, 'PE');
  });

  test('missing put side is blank rather than invented', () {
    final rows = OptionChainAssembler.rows(
      contracts: [
        contract(id: 'CE', expiry: expiryA, strike: 135000, side: OptionSide.call),
      ],
      expiry: expiryA,
    );
    expect(rows.single.put, isNull);
    expect(rows.single.call?.fundId, 'CE');
  });

  test('ATM is the nearest strike to spot', () {
    expect(
      OptionChainAssembler.atmStrikeMinor(
        strikes: const [130000, 132000, 134000],
        spotMinor: 131600,
      ),
      132000,
    );
  });

  test('future basis is future minus spot', () {
    expect(
      OptionChainAssembler.basisMinor(futureLtpMinor: 132100, spotMinor: 131600),
      500,
    );
    expect(
      OptionChainAssembler.basisMinor(futureLtpMinor: 132300, spotMinor: 131600),
      700,
    );
  });

  test('call and put intrinsic values', () {
    expect(
      OptionChainAssembler.intrinsicMinor(
        side: OptionSide.call,
        strikeMinor: 130000,
        spotMinor: 131600,
      ),
      1600,
    );
    expect(
      OptionChainAssembler.intrinsicMinor(
        side: OptionSide.put,
        strikeMinor: 130000,
        spotMinor: 128000,
      ),
      2000,
    );
  });

  test('moneyness for calls and puts', () {
    expect(
      OptionChainAssembler.moneyness(
        side: OptionSide.call,
        strikeMinor: 130000,
        spotMinor: 131600,
        atmMinor: 132000,
      ),
      OptionMoneyness.itm,
    );
    expect(
      OptionChainAssembler.moneyness(
        side: OptionSide.call,
        strikeMinor: 132000,
        spotMinor: 131600,
        atmMinor: 132000,
      ),
      OptionMoneyness.atm,
    );
    expect(
      OptionChainAssembler.moneyness(
        side: OptionSide.put,
        strikeMinor: 130000,
        spotMinor: 131600,
        atmMinor: 132000,
      ),
      OptionMoneyness.otm,
    );
  });
}
