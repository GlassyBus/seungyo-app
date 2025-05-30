import 'package:equatable/equatable.dart';

/// 구장 엔티티
class Stadium extends Equatable {
  const Stadium({
    required this.id,
    required this.name,
    required this.city,
    this.capacity,
  });

  final String id;
  final String name;
  final String city;
  final int? capacity;

  @override
  List<Object?> get props => [id, name, city, capacity];
}
