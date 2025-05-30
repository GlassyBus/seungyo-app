import 'stadium.dart';

/// 구장 데이터 모델
class StadiumModel {
  const StadiumModel({
    required this.id,
    required this.name,
    required this.city,
    this.capacity,
  });

  final String id;
  final String name;
  final String city;
  final int? capacity;

  /// JSON에서 생성
  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    return StadiumModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      capacity: json['capacity'] as int?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'capacity': capacity,
    };
  }

  /// 엔티티로 변환
  Stadium toEntity() {
    return Stadium(
      id: id,
      name: name,
      city: city,
      capacity: capacity,
    );
  }

  /// 엔티티에서 생성
  factory StadiumModel.fromEntity(Stadium entity) {
    return StadiumModel(
      id: entity.id,
      name: entity.name,
      city: entity.city,
      capacity: entity.capacity,
    );
  }
}
