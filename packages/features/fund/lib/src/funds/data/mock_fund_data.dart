import '../domain/entities/collateral_summary.dart';
import '../domain/entities/fund_activity.dart';
import '../domain/entities/fund_summary.dart';
import '../domain/entities/margin_breakdown.dart';

const mockFundSummary = FundSummary(
  availableToTrade: 245680.50,
  withdrawableBalance: 192450,
  availableCash: 210680.50,
  usedMargin: 35000,
  openingBalance: 220000,
  addedToday: 40000,
  withdrawnToday: 10000,
);

const mockCollateralSummary = CollateralSummary(
  total: 50000,
  equity: 35000,
  liquid: 15000,
);

const mockMarginBreakdown = MarginBreakdown(
  total: 35000,
  span: 18000,
  exposure: 7000,
  optionPremium: 6000,
  deliveryMargin: 4000,
);

const mockFundActivities = <FundActivity>[
  FundActivity(
    type: FundActivityType.deposit,
    amount: 40000,
    title: 'Funds Added',
    method: 'UPI',
    dateLabel: 'Today, 10:42 AM',
  ),
  FundActivity(
    type: FundActivityType.withdrawal,
    amount: 10000,
    title: 'Withdrawal',
    method: 'Bank Transfer',
    dateLabel: 'Yesterday, 04:15 PM',
  ),
  FundActivity(
    type: FundActivityType.deposit,
    amount: 25000,
    title: 'Funds Added',
    method: 'Net Banking',
    dateLabel: '18 Aug, 11:20 AM',
  ),
];
