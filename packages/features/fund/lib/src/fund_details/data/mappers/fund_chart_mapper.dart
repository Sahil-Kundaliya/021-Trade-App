import 'package:core_data/core_data.dart';

import '../../domain/entities/fund_details.dart';
import '../../domain/entities/option_chain.dart';
import '../../domain/entities/price_candle.dart';

abstract final class FundChartMapper {
  static List<PriceCandle> candles(Iterable<PriceCandleDto> dtos) => [
    for (final dto in dtos)
      PriceCandle.fromPrices(
        startedAt: dto.startedAt,
        open: dto.open,
        high: dto.high,
        low: dto.low,
        close: dto.close,
      ),
  ];

  static List<FundHistoryPoint> history(
    Iterable<PriceHistoryPointDto> dtos,
  ) => [
    for (final dto in dtos)
      FundHistoryPoint(date: dto.date, value: dto.value),
  ];
}

abstract final class OptionChainMapper {
  static OptionContract? contract(FundDto dto) {
    if (dto.instrumentType != 'OPTION') return null;
    final expiry = dto.expiryDate;
    final strike = dto.strikePrice;
    final optionType = dto.optionType?.toUpperCase();
    final underlying = dto.underlyingSymbol;
    if (expiry == null ||
        strike == null ||
        optionType == null ||
        underlying == null) {
      return null;
    }
    final exchange = TradeExchange.parse(dto.exchange);
    return OptionContract(
      fundId: dto.id,
      exchange: exchange,
      marketKey: MarketInstrumentKey(
        fundId: dto.id,
        exchange: exchange,
      ).value,
      symbol: dto.symbol,
      underlyingSymbol: underlying,
      expiry: expiry,
      strikeMinor: (strike * 100).round(),
      side: optionType == 'PE' ? OptionSide.put : OptionSide.call,
      ltpMinor: (dto.ltp * 100).round(),
      previousCloseMinor: (dto.previousClose * 100).round(),
      tickSizeMinor: (dto.tickSize * 100).round().clamp(1, 1 << 30),
      lotSize: dto.lotSize,
      openInterest: dto.openInterest,
      impliedVolatility: dto.impliedVolatility,
    );
  }

  static FutureOverview? future(FundDto dto) {
    if (dto.instrumentType != 'FUTURE' || dto.expiryDate == null) {
      return null;
    }
    final exchange = TradeExchange.parse(dto.exchange);
    return FutureOverview(
      fundId: dto.id,
      symbol: dto.symbol,
      marketKey: MarketInstrumentKey(
        fundId: dto.id,
        exchange: exchange,
      ).value,
      expiry: dto.expiryDate!,
      lotSize: dto.lotSize,
      ltpMinor: (dto.ltp * 100).round(),
      previousCloseMinor: (dto.previousClose * 100).round(),
      openInterest: dto.openInterest,
    );
  }

  static LiveInstrumentSeed seedFor(OptionContract contract) =>
      LiveInstrumentSeed(
        marketKey: contract.marketKey,
        fundId: contract.fundId,
        exchange: contract.exchange,
        assetType: LiveMarketAssetType.option,
        symbol: contract.symbol,
        ltpMinor: contract.ltpMinor,
        previousCloseMinor: contract.previousCloseMinor,
        tickSizeMinor: contract.tickSizeMinor,
      );

  static LiveInstrumentSeed equitySeed({
    required FundDto dto,
    required TradeExchange exchange,
  }) {
    final listing = dto.listingFor(exchange) ?? dto.listingFor(TradeExchange.nse);
    final resolved = listing == null ? dto : dto.forExchange(listing.exchange);
    return LiveInstrumentSeed.fromPrices(
      marketKey: MarketInstrumentKey(
        fundId: resolved.id,
        exchange: TradeExchange.parse(resolved.exchange),
      ).value,
      fundId: resolved.id,
      exchange: TradeExchange.parse(resolved.exchange),
      assetType: LiveMarketAssetType.equity,
      symbol: resolved.symbol,
      ltp: resolved.ltp,
      previousClose: resolved.previousClose,
      tickSize: resolved.tickSize,
    );
  }
}
