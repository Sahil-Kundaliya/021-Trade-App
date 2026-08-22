import '../domain/entities/holding.dart';
import '../domain/entities/portfolio_summary.dart';

const mockPortfolioSummary = PortfolioSummary(
  totalInvested: 450000,
  currentValue: 482640.50,
  totalPnl: 32640.50,
  totalPnlPercent: 7.25,
);

const mockHoldings = <Holding>[
  Holding(
    symbol: 'RELIANCE',
    companyName: 'Reliance Industries',
    quantity: 50,
    averageCost: 1320.40,
    ltp: 1452.30,
    currentValue: 72615,
    pnl: 6595,
    pnlPercent: 9.99,
  ),
  Holding(
    symbol: 'TCS',
    companyName: 'Tata Consultancy Services',
    quantity: 20,
    averageCost: 3510,
    ltp: 3425.60,
    currentValue: 68512,
    pnl: -1688,
    pnlPercent: -2.40,
  ),
  Holding(
    symbol: 'INFY',
    companyName: 'Infosys',
    quantity: 40,
    averageCost: 1410.50,
    ltp: 1486.20,
    currentValue: 59448,
    pnl: 3028,
    pnlPercent: 5.37,
  ),
  Holding(
    symbol: 'HDFCBANK',
    companyName: 'HDFC Bank',
    quantity: 60,
    averageCost: 1520,
    ltp: 1605,
    currentValue: 96300,
    pnl: 5100,
    pnlPercent: 5.59,
  ),
  Holding(
    symbol: 'ICICIBANK',
    companyName: 'ICICI Bank',
    quantity: 80,
    averageCost: 1125,
    ltp: 1260.50,
    currentValue: 100840,
    pnl: 10840,
    pnlPercent: 12.04,
  ),
  Holding(
    symbol: 'LT',
    companyName: 'Larsen & Toubro',
    quantity: 25,
    averageCost: 3046.40,
    ltp: 3397.02,
    currentValue: 84925.50,
    pnl: 8765.50,
    pnlPercent: 11.51,
  ),
];
