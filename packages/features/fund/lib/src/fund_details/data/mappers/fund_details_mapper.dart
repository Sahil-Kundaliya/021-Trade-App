import 'package:core_data/core_data.dart';

import '../../domain/entities/fund_details.dart';

abstract final class FundDetailsMapper {
  static FundDetails toDomain(FundDto dto) => FundDetails(
    id: dto.id,
    symbol: dto.symbol,
    companyName: dto.companyName,
    exchange: dto.exchange,
    category: dto.category,
    instrumentType: switch (dto.instrumentType) {
      'EQUITY' => FundInstrumentType.equity,
      'FUTURE' => FundInstrumentType.future,
      'OPTION' => FundInstrumentType.option,
      final value => throw TradingDataException(
        'Unsupported instrument type: $value.',
      ),
    },
    currency: dto.currency,
    ltp: dto.ltp,
    previousClose: dto.previousClose,
    change: dto.change,
    changePercent: dto.changePercent,
    open: dto.open,
    high: dto.high,
    low: dto.low,
    volume: dto.volume,
    lotSize: dto.lotSize,
    expiryDate: dto.expiryDate,
    strikePrice: dto.strikePrice,
    optionType: dto.optionType,
    underlyingSymbol: dto.underlyingSymbol,
    openInterest: dto.openInterest,
    impliedVolatility: dto.impliedVolatility,
    tags: dto.tags,
    marketDepth: FundMarketDepth(
      bids: dto.marketDepth.bids
          .map(
            (level) => FundDepthLevel(
              price: level.price,
              quantity: level.quantity,
              orderCount: level.orderCount,
            ),
          )
          .toList(),
      asks: dto.marketDepth.asks
          .map(
            (level) => FundDepthLevel(
              price: level.price,
              quantity: level.quantity,
              orderCount: level.orderCount,
            ),
          )
          .toList(),
      totalBidQuantity: dto.marketDepth.totalBidQuantity,
      totalAskQuantity: dto.marketDepth.totalAskQuantity,
    ),
    priceHistory: FundPriceHistory(
      oneMonth: dto.oneMonthPriceHistory
          .map(
            (point) => FundHistoryPoint(date: point.date, value: point.value),
          )
          .toList(),
      threeMonths: dto.threeMonthPriceHistory
          .map(
            (point) => FundHistoryPoint(date: point.date, value: point.value),
          )
          .toList(),
    ),
    marginDetails: FundMarginDetails(
      delivery: dto.marginDetails.delivery,
      intraday: dto.marginDetails.intraday,
      overnight: dto.marginDetails.overnight,
      span: dto.marginDetails.span,
      exposure: dto.marginDetails.exposure,
    ),
    collateralDetails: FundCollateralDetails(
      isEligible: dto.collateralDetails.isEligible,
      haircutPercent: dto.collateralDetails.haircutPercent,
      eligibleValue: dto.collateralDetails.eligibleValue,
      postHaircutValue: dto.collateralDetails.postHaircutValue,
    ),
    recentActivity: dto.recentActivity
        .map(
          (activity) => FundActivity(
            id: activity.id,
            type: activity.type,
            title: activity.title,
            description: activity.description,
            timestamp: activity.timestamp,
          ),
        )
        .toList(),
  );
}
