import '../entities/searchable_fund.dart';

abstract interface class SearchRepository {
  Future<List<SearchableFund>> getFunds();
}
