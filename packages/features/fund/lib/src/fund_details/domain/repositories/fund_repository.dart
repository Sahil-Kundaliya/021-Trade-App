import '../entities/fund_details.dart';

abstract interface class FundRepository {
  Future<FundDetails> getFundById(String fundId);
}

class FundNotFoundException implements Exception {
  const FundNotFoundException(this.fundId);
  final String fundId;
  @override
  String toString() => 'Fund not found: $fundId';
}
