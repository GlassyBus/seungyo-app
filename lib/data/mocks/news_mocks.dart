import 'package:seungyo/models/news_item.dart';

/// 뉴스 관련 Mock 데이터
class NewsMocks {
  /// 최신 뉴스 목록
  static List<NewsItem> latestNews = [
    NewsItem(
      title: "'전 NC' 하트, 5시즌 만에 빅리그 복귀해 MLB 첫 승리",
      description:
          "샌디에이고 유니폼 입고 치른 첫 경기서 5이닝 2실점 2024년 한국프로야구 KBO리그 투수 부문 골든글러브 수상자인 카일 하트(32·샌디에이고... KBO리그는 빅리그 복귀를 위한 지렛대였다.",
      sourceUrl: 'https://example.com/news/1',
      publishedDate: DateTime(2024, 4, 5),
    ),
    NewsItem(
      title: "\"2030세대가 푹 빠졌다\"…티빙, 'KBO 리그' 개막에 야구팬 몰려",
      description:
          "정규 시즌이 시작되기도 전에 팬들의 관심은 이미 달아올랐다. 올해 KBO 리그 시범경기 시청 UV는 전년 대비 15% 증가,",
      sourceUrl: 'https://example.com/news/2',
      publishedDate: DateTime(2024, 4, 4),
    ),
    NewsItem(
      title: "'창원의 비극' 슬픔 함께한 KBO리그…팬들도 '응원 자제'",
      description:
          "2024 한국시리즈 리턴매치다. 지난해에는 KIA가 12승4패로 압도했다. KIA는 이 분위기를 잇고 싶다. 삼성은 반을 원한다.",
      sourceUrl: 'https://example.com/news/3',
      publishedDate: DateTime(2024, 4, 3),
    ),
  ];

  /// 인기 뉴스 목록
  static List<NewsItem> trendingNews = [
    NewsItem(
      title: "KBO 리그 개막 첫 주, 평균 관중 1만 5천명으로 역대 최고치",
      description:
          "코로나19 이후 처음으로 제한 없이 개막한 2024 KBO 리그가 첫 주 평균 관중 1만 5천명을 기록하며 역대 최고 흥행을 기록했다.",
      imageUrl: 'assets/images/trending1.png',
      sourceUrl: 'https://example.com/trending/1',
      publishedDate: DateTime(2024, 4, 7),
    ),
    NewsItem(
      title: "KBO, '배트 던지기' 규정 강화...벌금 및 출장정지 처분 확대",
      description:
          "한국야구위원회(KBO)가 올 시즌부터 배트 던지기 행위에 대한 제재를 강화한다고 발표했다. 심판진의 재량에 따라 벌금과 출장정지 처분이 확대된다.",
      imageUrl: 'assets/images/trending2.png',
      sourceUrl: 'https://example.com/trending/2',
      publishedDate: DateTime(2024, 4, 6),
    ),
  ];

  /// 팀별 뉴스 목록 - 'LG' 팀 예시
  static List<NewsItem> lgTeamNews = [
    NewsItem(
      title: "LG 트윈스, 새 외국인 타자 영입 임박...메이저리그 경력 보유",
      description:
          "LG 트윈스가 메이저리그에서 활약한 새 외국인 타자 영입을 앞두고 있다. 구단 관계자는 '최종 계약 단계만 남았다'고 밝혔다.",
      imageUrl: 'assets/images/lg_news1.png',
      sourceUrl: 'https://example.com/lg/1',
      publishedDate: DateTime(2024, 4, 5),
    ),
    NewsItem(
      title: "LG 트윈스 오지환, 개인 통산 1500안타 달성",
      description: "LG 트윈스의 오지환이 프로 입단 후 1500안타를 달성했다. 현역 선수 중 12번째 기록이다.",
      imageUrl: 'assets/images/lg_news2.png',
      sourceUrl: 'https://example.com/lg/2',
      publishedDate: DateTime(2024, 4, 2),
    ),
  ];
}
