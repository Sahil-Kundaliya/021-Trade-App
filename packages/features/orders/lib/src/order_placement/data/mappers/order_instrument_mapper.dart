import 'package:core_data/core_data.dart';

import '../../domain/entities/order_instrument.dart';
import '../../domain/enums/order_enums.dart';

abstract final class OrderInstrumentMapper {
  static OrderInstrument toDomain(FundDto dto) {
    final type = switch (dto.instrumentType.trim().toUpperCase()) {
      'FUTURE' => OrderInstrumentType.future,
      'OPTION' => OrderInstrumentType.option,
      _ => OrderInstrumentType.equity,
    };
    final exchange = dto.exchange.toUpperCase() == 'BSE'
        ? TradeExchange.bse
        : TradeExchange.nse;
    return OrderInstrument(
      id: dto.id,
      symbol: dto.symbol,
      companyName: dto.companyName,
      instrumentType: type,
      availableExchanges: type == OrderInstrumentType.equity
          ? const [TradeExchange.nse, TradeExchange.bse]
          : [exchange],
      defaultExchange: exchange,
      ltp: dto.ltp,
      change: dto.change,
      changePercent: dto.changePercent,
      lotSize: dto.lotSize < 1 ? 1 : dto.lotSize,
      tickSize: dto.tickSize,
      previousClose: dto.previousClose,
      allowedOrderTypes: TradeOrderType.values,
      allowedProducts: type == OrderInstrumentType.equity
          ? const [TradeProduct.delivery, TradeProduct.intraday]
          : const [TradeProduct.intraday, TradeProduct.overnight],
    );
  }
}
