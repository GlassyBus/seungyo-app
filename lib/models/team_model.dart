import 'team.dart';

/// 팀 데이터 모델
class TeamModel {
  const TeamModel({
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

  /// JSON에서 생성
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      primaryColor: json['primaryColor'] as String,
      secondaryColor: json['secondaryColor'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'logoUrl': logoUrl,
    };
  }

  /// 엔티티로 변환
  Team toEntity() {
    return Team(
      id: id,
      name: name,
      shortName: shortName,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      logoUrl: logoUrl,
    );
  }

  /// 엔티티에서 생성
  factory TeamModel.fromEntity(Team entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      shortName: entity.shortName,
      primaryColor: entity.primaryColor,
      secondaryColor: entity.secondaryColor,
      logoUrl: entity.logoUrl,
    );
  }
}
