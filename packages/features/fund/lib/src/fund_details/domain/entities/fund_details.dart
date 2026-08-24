import 'package:core_data/core_data.dart';

enum FundInstrumentType { equity, future, option }

class FundDetails {
  FundDetails({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.category,
    required this.instrumentType,
    required this.currency,
    required this.ltp,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.tickSize,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.lotSize,
    required this.expiryDate,
    required this.strikePrice,
    required this.optionType,
    required this.underlyingSymbol,
    required this.openInterest,
    required this.impliedVolatility,
    required List<String> tags,
    required this.marketDepth,
    required this.priceHistory,
    required this.marginDetails,
    required this.collateralDetails,
    required this.companyProfile,
    required List<FundActivity> recentActivity,
  }) : tags = List.unmodifiable(tags),
       recentActivity = List.unmodifiable(recentActivity);

  final String id;
  final String symbol;
  final String companyName;
  final TradeExchange exchange;
  String get marketKey =>
      MarketInstrumentKey(fundId: id, exchange: exchange).value;
  final String category;
  final FundInstrumentType instrumentType;
  final String currency;
  final double ltp;
  final double previousClose;
  final double change;
  final double changePercent;
  final double tickSize;
  final double open;
  final double high;
  final double low;
  final int volume;
  final int lotSize;
  final DateTime? expiryDate;
  final double? strikePrice;
  final String? optionType;
  final String? underlyingSymbol;
  final int? openInterest;
  final double? impliedVolatility;
  final List<String> tags;
  final FundMarketDepth marketDepth;
  final FundPriceHistory priceHistory;
  final FundMarginDetails marginDetails;
  final FundCollateralDetails collateralDetails;
  final CompanyProfile companyProfile;
  final List<FundActivity> recentActivity;

  FundDetails withLivePrice(LivePriceTick tick) => FundDetails(
    id: id,
    symbol: symbol,
    companyName: companyName,
    exchange: exchange,
    category: category,
    instrumentType: instrumentType,
    currency: currency,
    ltp: tick.ltp,
    previousClose: previousClose,
    change: tick.change,
    changePercent: tick.changePercent,
    tickSize: tickSize,
    open: open,
    high: high,
    low: low,
    volume: volume,
    lotSize: lotSize,
    expiryDate: expiryDate,
    strikePrice: strikePrice,
    optionType: optionType,
    underlyingSymbol: underlyingSymbol,
    openInterest: openInterest,
    impliedVolatility: impliedVolatility,
    tags: tags,
    marketDepth: marketDepth,
    priceHistory: priceHistory,
    marginDetails: marginDetails,
    collateralDetails: collateralDetails,
    companyProfile: companyProfile,
    recentActivity: recentActivity,
  );

  FundDetails withRecentActivity(List<FundActivity> activity) => FundDetails(
    id: id,
    symbol: symbol,
    companyName: companyName,
    exchange: exchange,
    category: category,
    instrumentType: instrumentType,
    currency: currency,
    ltp: ltp,
    previousClose: previousClose,
    change: change,
    changePercent: changePercent,
    tickSize: tickSize,
    open: open,
    high: high,
    low: low,
    volume: volume,
    lotSize: lotSize,
    expiryDate: expiryDate,
    strikePrice: strikePrice,
    optionType: optionType,
    underlyingSymbol: underlyingSymbol,
    openInterest: openInterest,
    impliedVolatility: impliedVolatility,
    tags: tags,
    marketDepth: marketDepth,
    priceHistory: priceHistory,
    marginDetails: marginDetails,
    collateralDetails: collateralDetails,
    companyProfile: companyProfile,
    recentActivity: activity,
  );
}

class CompanyProfile {
  const CompanyProfile({
    required this.legalName,
    required this.industry,
    required this.registeredOffice,
    required this.corporateIdentityNumber,
    required this.website,
    required this.email,
    required this.phone,
    required this.directors,
    required this.management,
  });

  final String legalName;
  final String industry;
  final String registeredOffice;
  final String corporateIdentityNumber;
  final String website;
  final String email;
  final String phone;
  final List<CompanyPerson> directors;
  final List<CompanyPerson> management;
}

class CompanyPerson {
  const CompanyPerson({required this.name, required this.role});

  final String name;
  final String role;
}

class FundMarketDepth {
  FundMarketDepth({
    required List<FundDepthLevel> bids,
    required List<FundDepthLevel> asks,
    required this.totalBidQuantity,
    required this.totalAskQuantity,
  }) : bids = List.unmodifiable(bids.take(10)),
       asks = List.unmodifiable(asks.take(10));
  final List<FundDepthLevel> bids;
  final List<FundDepthLevel> asks;
  final int totalBidQuantity;
  final int totalAskQuantity;
}

class FundDepthLevel {
  const FundDepthLevel({
    required this.price,
    required this.quantity,
    required this.orderCount,
  });
  final double price;
  final int quantity;
  final int orderCount;
}

class FundPriceHistory {
  FundPriceHistory({
    required List<FundHistoryPoint> oneMonth,
    required List<FundHistoryPoint> threeMonths,
  }) : oneMonth = List.unmodifiable(oneMonth),
       threeMonths = List.unmodifiable(threeMonths);
  final List<FundHistoryPoint> oneMonth;
  final List<FundHistoryPoint> threeMonths;
}

class FundHistoryPoint {
  const FundHistoryPoint({required this.date, required this.value});
  final DateTime date;
  final double value;
}

class FundMarginDetails {
  const FundMarginDetails({
    this.delivery,
    this.intraday,
    this.overnight,
    this.span,
    this.exposure,
  });
  final double? delivery;
  final double? intraday;
  final double? overnight;
  final double? span;
  final double? exposure;
}

class FundCollateralDetails {
  const FundCollateralDetails({
    required this.isEligible,
    required this.haircutPercent,
    required this.eligibleValue,
    required this.postHaircutValue,
  });
  final bool isEligible;
  final double haircutPercent;
  final double eligibleValue;
  final double postHaircutValue;
}

class FundActivity {
  const FundActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
}
