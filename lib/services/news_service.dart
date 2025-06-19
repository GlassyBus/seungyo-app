class NewsService {
  // 실제 앱에서는 실제 API를 사용해야 합니다
  Future<List<Map<String, dynamic>>> getNewsByKeyword(
    String keyword, {
    int limit = 4,
  }) async {
    // 실제 API 호출 대신 모의 데이터 반환
    await Future.delayed(const Duration(milliseconds: 800));

    final mockNews = [
      {
        "title": "LG 고우석, MLB 마이애미서 방출…KBO 복귀 기대감 ↑",
        "content":
            "마이애미 말린스 산하 트리플A에서 방출된 고우석(27)이 자유계약(FA) 자격을 얻으면서, 원소속팀 LG 트윈스로의 복귀 가능성이 본격적으로 거론되고 있다. 차명석 단장은 “선수 본인의 의사가 가장 중요하다”고 밝혔다.",
        "imageUrl":
            "https://thumbnews.nateimg.co.kr/view610///news.nateimg.co.kr/orgImg/sd/2025/06/18/131828691.1.jpg",
        "url": "https://sports.news.nate.com/view/20250618n03745",
        "publishedAt": "방금 전",
        "category": "이적·복귀",
      },
      {
        "title": "롯데, 사직서 한화 꺾고 2연패 탈출…신인 포수 박재엽 데뷔 첫 홈런!",
        "content":
            "6월 18일 사직구장에서 열린 롯데-한화전에서 6‑3 승리를 거둔 롯데가 2연패에서 탈출했다. 특히 신인 포수 박재엽이 데뷔 첫 타석에서 3점 홈런 포함 4출루의 맹활약을 펼쳤다.",
        "imageUrl":
            "https://news.kbs.co.kr/data/news/2025/06/18/20250618_7eOPjV.jpg",
        "url": "https://news.kbs.co.kr/news/pc/view/view.do?ncd=8282030",
        "publishedAt": "2시간 전",
        "category": "경기결과",
      },
      {
        "title": "두산 베어스, 이승엽 감독 자진 사퇴…코치진 재정비 돌입",
        "content":
            "6월 2일 이승엽 감독이 성적 부진을 이유로 자진 사퇴했고, 조성환 코치가 감독대행으로 나서면서 코치진 개편에 착수했다.",
        "imageUrl":
            "https://pimg.mk.co.kr/news/cms/202506/03/news-p.v1.20250602.02041dd88dd448f4a279f7bf2ce31b2e_P1.jpg",
        "url": "https://www.mk.co.kr/news/sports/11333142",
        "publishedAt": "2주 전",
        "category": "구단소식",
      },
      {
        "title": "삼성, ‘레예스 대체’ 외국인 투수 헤르손 가라비토 영입",
        "content":
            "삼성 라이온즈가 부상 이탈한 데니 레예스를 대체할 새 외국인 투수 헤르손 가라비토(30)를 잔여 시즌 35만ドル 조건으로 영입했다.",
        "imageUrl":
            "https://dimg.donga.com/wps/SPORTS/IMAGE/2025/06/19/131839102.1.jpg",
        "url":
            "https://sports.donga.com/sports/article/all/20250619/131839089/1",
        "publishedAt": "오늘",
        "category": "이적·복귀",
      },
      {
        "title": "SSG 김광현, 2년 36억 연장 계약…200승 도전에 속도",
        "content":
            "SSG 랜더스가 에이스 김광현과 2년 총 36억원(연봉 30억·옵션 6억) 연장계약을 체결하며 통산 200승 도전에 박차를 가한다.",
        "imageUrl":
            "https://img1.daumcdn.net/thumb/R658x0.q70/?fname=https://t1.daumcdn.net/news/202506/15/551714-qBABr9u/20250615185322172lphd.jpg",
        "url": "https://v.daum.net/v/20250615185320116",
        "publishedAt": "6일 전",
        "category": "구단소식",
      },
      {
        "title": "NC, LG전서 9‑8 승리…대타진 집중력 빛났다",
        "content":
            "6월 18일 잠실에서 펼쳐진 NC와 LG의 경기에서 NC가 9‑8 승리를 거두며, 특히 대타진의 집중력이 돋보였다.",
        "imageUrl":
            "https://img4.daumcdn.net/thumb/R658x0.q70/?fname=https://t1.daumcdn.net/news/202506/19/maniareport/20250619074515187simq.jpg",
        "url": "https://v.daum.net/v/pFxVHdNfhU",
        "publishedAt": "오늘",
        "category": "경기결과",
      },
      {
        "title": "KT, 6월 중순 이후 반등…중위권 경쟁 속 반등 노린다",
        "content":
            "KT는 6월 들어 연승을 기록하며 중위권 경쟁을 이어가고 있다. 팀 관계자는 “다음 시리즈에서 집중력이 관건”이라고 밝혔다.",
        "imageUrl":
            "https://ypzxxdrj8709.edge.naverncp.com/data2/content/image/2025/06/09/.cache/512/20250609580031.jpg",
        "url": "https://www.kyeonggi.com/article/20250609580030",
        "publishedAt": "1주 전",
        "category": "팀전략",
      },
    ];

    // 키워드로 필터링 (팀명이 포함된 뉴스 우선 표시)
    List<Map<String, dynamic>> filteredNews = [];

    // 1. 키워드가 제목에 포함된 뉴스 먼저 추가
    filteredNews.addAll(
      mockNews.where((news) {
        return news['title']!.contains(keyword);
      }),
    );

    // 2. 키워드가 내용에 포함된 뉴스 추가 (중복 제거)
    final titleMatches = filteredNews.map((n) => n['title']).toSet();
    filteredNews.addAll(
      mockNews.where((news) {
        return !titleMatches.contains(news['title']) &&
            news['content']!.contains(keyword);
      }),
    );

    // 3. 키워드 관련 뉴스가 부족하면 일반 야구 뉴스로 채우기
    if (filteredNews.length < limit) {
      final existingTitles = filteredNews.map((n) => n['title']).toSet();
      filteredNews.addAll(
        mockNews.where((news) {
          return !existingTitles.contains(news['title']);
        }),
      );
    }

    // 최대 limit 개수만큼 반환
    return filteredNews.take(limit).toList();
  }
}
