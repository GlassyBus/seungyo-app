import 'package:equatable/equatable.dart';

/// 구장 엔티티
class Stadium extends Equatable {
  const Stadium({
    required this.id,
    required this.name,
    required this.city,
    this.capacity,
    this.address,
    this.latitude,
    this.longitude,
    this.homeTeam,
    this.openedYear,
    this.description,
  });

  final String id;
  final String name;
  final String city;
  final int? capacity;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? homeTeam;
  final int? openedYear;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    city,
    capacity,
    address,
    latitude,
    longitude,
    homeTeam,
    openedYear,
    description,
  ];

  /// JSON으로부터 Stadium 객체 생성
  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      capacity: json['capacity'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      homeTeam: json['homeTeam'],
      openedYear: json['openedYear'],
      description: json['description'],
    );
  }

  /// Stadium 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'capacity': capacity,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'homeTeam': homeTeam,
      'openedYear': openedYear,
      'description': description,
    };
  }
}
