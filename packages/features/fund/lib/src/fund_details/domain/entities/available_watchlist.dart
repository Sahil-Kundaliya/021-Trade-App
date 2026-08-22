class AvailableWatchlist {
  AvailableWatchlist({
    required this.id,
    required this.name,
    required List<String> fundIds,
  }) : fundIds = List.unmodifiable(fundIds);
  final String id;
  final String name;
  final List<String> fundIds;
  bool containsFund(String fundId) => fundIds.contains(fundId);

  AvailableWatchlist withFund(String fundId) => containsFund(fundId)
      ? this
      : AvailableWatchlist(id: id, name: name, fundIds: [...fundIds, fundId]);
}
