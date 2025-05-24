import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/news_item.dart';

/// 최근 뉴스 컴포넌트
///
/// 야구 관련 최근 뉴스 목록을 표시합니다.
class NewsComponent extends StatelessWidget {
  /// 표시할 뉴스 항목 목록
  final List<NewsItem>? newsItems;

  /// 섹션 제목
  final String title;

  /// 생성자
  const NewsComponent({Key? key, this.newsItems, this.title = '최근 소식은'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 뉴스 아이템이 null이거나 비어있으면 기본 뉴스 목록 생성
    final items = newsItems ?? _getDefaultNewsItems();
    final hasNews = items.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
              color: Color(0xFF09004C),
            ),
          ),
          const SizedBox(height: 12),
          hasNews
              ? Column(
                children:
                    items
                        .map(
                          (item) => _buildNewsItem(
                            image: item.imageUrl,
                            title: item.title,
                            description: item.description,
                          ),
                        )
                        .toList(),
              )
              : _buildEmptyNewsView(),
        ],
      ),
    );
  }

  /// 기본 뉴스 아이템 목록 생성
  List<NewsItem> _getDefaultNewsItems() {
    return [
      NewsItem(
        title: "'전 NC' 하트, 5시즌 만에 빅리그 복귀해 MLB 첫 승리",
        description:
            "샌디에이고 유니폼 입고 치른 첫 경기서 5이닝 2실점 2024년 한국프로야구 KBO리그 투수 부문 골든글러브 수상자인 카일 하트(32·샌디에이고... KBO리그는 빅리그 복귀를 위한 지렛대였다.",
      ),
      NewsItem(
        title: "\"2030세대가 푹 빠졌다\"…티빙, 'KBO 리그' 개막에 야구팬 몰려",
        description:
            "정규 시즌이 시작되기도 전에 팬들의 관심은 이미 달아올랐다. 올해 KBO 리그 시범경기 시청 UV는 전년 대비 15% 증가,",
        imageUrl: '',
      ),
      NewsItem(
        title: "'창원의 비극' 슬픔 함께한 KBO리그…팬들도 '응원 자제'",
        description:
            "2024 한국시리즈 리턴매치다. 지난해에는 KIA가 12승4패로 압도했다. KIA는 이 분위기를 잇고 싶다. 삼성은 반을 원한다.",
      ),
    ];
  }

  /// 뉴스가 없을 때 표시할 위젯
  Widget _buildEmptyNewsView() {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/silent-120px.png', width: 70, height: 70),
          const SizedBox(height: 12),
          const Text(
            '소식이 없어요.',
            style: TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF09004C),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 뉴스 항목 위젯을 빌드합니다.
  Widget _buildNewsItem({
    required String image,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNewsImage(image),
          const SizedBox(width: 10),
          _buildNewsContent(title, description),
        ],
      ),
    );
  }

  /// 뉴스 이미지를 빌드합니다.
  Widget _buildNewsImage(String image) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE9EBF0),
      ),
      child:
          image.isEmpty
              ? Center(
                child: SvgPicture.asset(
                  'assets/icons/wings-57px.svg',
                  width: 57,
                  height: 69,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFCDD3DD),
                    BlendMode.srcIn,
                  ),
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
    );
  }

  /// 뉴스 제목과 내용을 빌드합니다.
  Widget _buildNewsContent(String title, String description) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'KBO Dia Gothic',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.48,
                color: Color(0xFF100F21),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'KBO Dia Gothic',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.36,
                color: Color(0xFF7E8695),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
