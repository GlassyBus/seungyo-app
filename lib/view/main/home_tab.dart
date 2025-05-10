import 'package:flutter/material.dart';
import 'widgets/greeting_section.dart';
import 'widgets/record_section.dart';
import 'widgets/match_section.dart';
import 'widgets/match_empty_section.dart';
import 'widgets/match_cancel_section.dart';
import 'widgets/news_section.dart';
import 'widgets/news_empty_section.dart';

class HomeTab extends StatelessWidget {
  // 실제 데이터는 ViewModel/Provider 등에서 받아오도록 설계
  final bool hasMatch; // 오늘 경기 있음
  final bool matchCanceled; // 오늘 경기 취소
  final bool hasNews; // 뉴스 있음

  const HomeTab({
    super.key,
    this.hasMatch = true,
    this.matchCanceled = false,
    this.hasNews = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      children: [
        const GreetingSection(),
        const SizedBox(height: 24),
        const RecordSection(),
        const SizedBox(height: 24),
        // 경기 섹션 분기
        if (matchCanceled)
          const MatchCancelSection()
        else if (hasMatch)
          const MatchSection()
        else
          const MatchEmptySection(),
        const SizedBox(height: 24),
        // 뉴스 섹션 분기
        if (hasNews) const NewsSection() else const NewsEmptySection(),
      ],
    );
  }
}
