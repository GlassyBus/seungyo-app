import '../models/news_item.dart';
import '../../../data/mocks/mocks.dart';

/// 뉴스 데이터 접근을 위한 Repository
///
/// 뉴스 정보 조회, 필터링 등의 기능을 제공합니다.
class NewsRepository {
  // 싱글톤 패턴 구현
  static final NewsRepository _instance = NewsRepository._internal();

  factory NewsRepository() {
    return _instance;
  }

  NewsRepository._internal();

  /// 특정 날짜의 뉴스 목록을 반환합니다.
  List<NewsItem> getNewsByDate(DateTime date) {
    // 날짜에 따라 다른 뉴스 데이터 반환
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    switch (dateStr) {
      case '2025.04.08':
        return NewsMocks.latestNews;
      case '2025.04.07':
        // 4월 7일은 뉴스가 없는 날
        return [];
      case '2025.04.13':
        // 4월 13일은 뉴스가 있음
        return NewsMocks.latestNews;
      default:
        return NewsMocks.latestNews;
    }
  }

  /// 최신 뉴스 목록을 반환합니다.
  List<NewsItem> getLatestNews() {
    // 더미 데이터 - 실제로는 API 호출 등으로 데이터를 가져옴
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

  /// 특정 날짜에 뉴스가 있는지 여부를 반환합니다.
  bool hasNewsForDate(DateTime date) {
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    // 2025.04.07은 뉴스가 없는 날로 가정
    return dateStr != '2025.04.07';
  }

  /// 키워드로 뉴스를 검색합니다.
  List<NewsItem> searchNews(String keyword) {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 여기서는 단순히 키워드가 제목이나 내용에 포함된 뉴스만 필터링
    if (keyword.isEmpty) {
      return [];
    }

    return getLatestNews().where((news) {
      return news.title.toLowerCase().contains(keyword.toLowerCase()) ||
          news.description.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  /// 특정 팀 관련 뉴스를 반환합니다.
  List<NewsItem> getNewsByTeam(String teamName) {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 여기서는 팀 이름으로 검색
    if (teamName.toLowerCase() == 'lg' || teamName.toLowerCase() == 'lg 트윈스') {
      return NewsMocks.lgTeamNews;
    }

    return searchNews(teamName);
  }

  /// 인기 뉴스 목록을 반환합니다.
  List<NewsItem> getTrendingNews() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return NewsMocks.trendingNews;
  }
}
