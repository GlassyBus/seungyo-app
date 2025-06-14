import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // 실제 앱에서는 실제 API를 사용해야 합니다
  Future<List<Map<String, dynamic>>> getNewsByKeyword(String keyword, {int limit = 4}) async {
    // 실제 API 호출 대신 모의 데이터 반환
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockNews = [
      {
        'title': "'전 NC' 하트, 5시즌 만에 빅리그 복귀...",
        'content': "샌디에이고 유니폼 입고 첫 경기에서 2실점으로 호투를 펼쳤다. 실점 2024년 한국프로야구 KBO리그 투수 부문 1위.",
        'imageUrl': 'https://via.placeholder.com/100x80?text=Baseball',
        'url': 'https://example.com/news/1',
        'publishedAt': '2시간 전',
        'category': '해외야구',
      },
      {
        'title': '"2030세대가 폭 빠졌다"...티빙, 시청률 급상승',
        'content': "정규 시즌이 시작되기도 전에 팬들의 관심은 이미 달아올랐다. 올해 KBO 리그 시범경기 시청 UV 수치가 작년 대비 30% 증가.",
        'imageUrl': 'https://via.placeholder.com/100x80?text=Stats',
        'url': 'https://example.com/news/2',
        'publishedAt': '4시간 전',
        'category': 'KBO',
      },
      {
        'title': "'창원의 비극' 슬픔 잠재운 KBO리그",
        'content': "2024 한국시리즈 리턴매치가 기대된다. 지난해에는 KIA가 12승4패로 압도했다. KIA는 이 분위기를 잇고 싶다.",
        'imageUrl': 'https://via.placeholder.com/100x80?text=Game',
        'url': 'https://example.com/news/3',
        'publishedAt': '6시간 전',
        'category': 'KBO',
      },
      {
        'title': "두산, 외국인 타자 교체 검토 중...'부진한 성적에 고심'",
        'content': "두산 베어스가 외국인 타자 교체를 검토 중이다. 시즌 초반 부진한 성적에 구단은 대책 마련에 고심하고 있다.",
        'imageUrl': 'https://via.placeholder.com/100x80?text=Doosan',
        'url': 'https://example.com/news/4',
        'publishedAt': '8시간 전',
        'category': '구단소식',
      },
    ];
    
    // 키워드로 필터링 (실제로는 API에서 필터링)
    final filteredNews = mockNews.where((news) {
      return news['title']!.contains(keyword) || 
             news['content']!.contains(keyword);
    }).toList();
    
    // 최대 limit 개수만큼 반환
    return filteredNews.take(limit).toList();
  }
}
