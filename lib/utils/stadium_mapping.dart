/// 경기장 매핑 유틸리티 클래스
class StadiumMapping {
  /// 경기장 이름과 홈팀을 기반으로 최적의 경기장 ID를 반환
  static String? getBestStadiumId(String stadiumName, String homeTeam) {
    // 홈팀 기반 경기장 매핑
    const teamStadiumMapping = {
      '두산': 'jamsil',      // 잠실야구장
      'LG': 'jamsil',        // 잠실야구장
      '키움': 'gocheok',     // 고척스카이돔
      'SSG': 'munhak',       // 문학경기장
      '삼성': 'daegu',       // 대구삼성라이온즈파크
      '한화': 'daejeon',     // 한화생명이글스파크
      'NC': 'changwon',      // 창원NC파크
      '롯데': 'sajik',       // 사직야구장
      'KIA': 'gwangju',      // 광주-기아챔피언스필드
      'KT': 'suwon',         // 수원KT위즈파크
    };

    // 경기장 이름 기반 매핑
    const stadiumNameMapping = {
      '잠실': 'jamsil',
      '잠실야구장': 'jamsil',
      '잠실베이스볼파크': 'jamsil',
      '고척': 'gocheok',
      '고척스카이돔': 'gocheok',
      '고척돔': 'gocheok',
      '문학': 'munhak',
      '문학경기장': 'munhak',
      'SSG랜더스필드': 'munhak',
      '대구': 'daegu',
      '대구삼성라이온즈파크': 'daegu',
      '라이온즈파크': 'daegu',
      '대전': 'daejeon',
      '한화생명이글스파크': 'daejeon',
      '이글스파크': 'daejeon',
      '창원': 'changwon',
      '창원NC파크': 'changwon',
      'NC파크': 'changwon',
      '사직': 'sajik',
      '사직야구장': 'sajik',
      '사직베이스볼파크': 'sajik',
      '광주': 'gwangju',
      '광주-기아챔피언스필드': 'gwangju',
      '챔피언스필드': 'gwangju',
      '기아챔피언스필드': 'gwangju',
      '수원': 'suwon',
      '수원KT위즈파크': 'suwon',
      'KT위즈파크': 'suwon',
      '위즈파크': 'suwon',
    };

    // 1. 경기장 이름으로 직접 매핑 시도
    String? stadiumId = stadiumNameMapping[stadiumName];
    if (stadiumId != null) {
      return stadiumId;
    }

    // 2. 부분 문자열 매치 시도
    for (String key in stadiumNameMapping.keys) {
      if (stadiumName.contains(key) || key.contains(stadiumName)) {
        return stadiumNameMapping[key];
      }
    }

    // 3. 홈팀 기반 매핑 시도
    stadiumId = teamStadiumMapping[homeTeam];
    if (stadiumId != null) {
      return stadiumId;
    }

    // 4. 홈팀 부분 문자열 매치 시도
    for (String team in teamStadiumMapping.keys) {
      if (homeTeam.contains(team) || team.contains(homeTeam)) {
        return teamStadiumMapping[team];
      }
    }

    // 5. 매핑을 찾을 수 없는 경우 null 반환
    print('StadiumMapping: Could not map stadium "$stadiumName" with home team "$homeTeam"');
    return null;
  }
} 