import 'package:equatable/equatable.dart';

/// 팀 엔티티
class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        shortName,
        primaryColor,
        secondaryColor,
        logoUrl,
      ];
}
