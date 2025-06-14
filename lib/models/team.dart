import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 팀 엔티티
class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.primaryColor,
    required this.secondaryColor,
    this.englishName,
    this.logo,
    this.city,
    this.stadium,
    this.foundedYear,
    this.description,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final Color primaryColor;
  final Color secondaryColor;
  final String? englishName;
  final String? logo;
  final String? city;
  final String? stadium;
  final int? foundedYear;
  final String? description;
  final String? logoUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    primaryColor,
    secondaryColor,
    englishName,
    logo,
    city,
    stadium,
    foundedYear,
    description,
    logoUrl,
  ];

  /// JSON으로부터 Team 객체 생성
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      shortName: json['shortName'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      englishName: json['englishName'],
      logo: json['logo'],
      city: json['city'],
      stadium: json['stadium'],
      foundedYear: json['foundedYear'],
      description: json['description'],
      logoUrl: json['logoUrl'],
    );
  }

  /// Team 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'englishName': englishName,
      'logo': logo,
      'city': city,
      'stadium': stadium,
      'foundedYear': foundedYear,
      'description': description,
      'logoUrl': logoUrl,
    };
  }
}
