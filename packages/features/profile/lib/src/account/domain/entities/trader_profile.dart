import 'package:flutter/foundation.dart';

@immutable
final class TraderProfile {
  const TraderProfile({
    required this.fullName,
    required this.clientId,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
    required this.accountType,
  });

  final String fullName;
  final String clientId;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final String accountType;
}
