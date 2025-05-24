import 'package:flutter/material.dart';

/// 뉴스 항목 모델
class NewsItem {
  /// 뉴스 제목
  final String title;

  /// 뉴스 설명/내용
  final String description;

  /// 뉴스 이미지 경로
  final String imageUrl;

  /// 원본 기사 URL
  final String? sourceUrl;

  /// 게시 날짜
  final DateTime? publishedDate;

  /// 생성자
  const NewsItem({
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.sourceUrl,
    this.publishedDate,
  });

  /// 팩토리 메서드 - 기본값 설정된 인스턴스 생성
  factory NewsItem.defaultNews() {
    return const NewsItem(
      title: '뉴스 제목',
      description: '뉴스 내용이 여기에 표시됩니다.',
      imageUrl: '',
    );
  }
}
