import 'package:equatable/equatable.dart';

/// 사용자 프로필 모델
class UserProfile extends Equatable {
  const UserProfile({
    required this.nickname,
    required this.favoriteTeamId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String nickname;
  final String favoriteTeamId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// JSON으로부터 UserProfile 객체 생성
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'],
      favoriteTeamId: json['favoriteTeamId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// UserProfile 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'favoriteTeamId': favoriteTeamId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 객체 복사 메서드
  UserProfile copyWith({
    String? nickname,
    String? favoriteTeamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      favoriteTeamId: favoriteTeamId ?? this.favoriteTeamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [nickname, favoriteTeamId, createdAt, updatedAt];
}
