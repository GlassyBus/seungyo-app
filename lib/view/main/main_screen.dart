import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'components/footer_component.dart';
import 'components/games_today_component.dart';
import 'components/header_component.dart';
import 'components/news_component.dart';
import 'components/profile_component.dart';
import 'components/record_stats_component.dart';
import 'repository/game_repository.dart';
import 'repository/news_repository.dart';
import 'repository/user_repository.dart';
import 'package:seungyo/view/record/record_screen.dart';

/// 메인 스크린
///
/// 앱의 메인 화면을 표시합니다.
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GameRepository _gameRepository = GameRepository();
  final NewsRepository _newsRepository = NewsRepository();
  final UserRepository _userRepository = UserRepository();

  int _currentTabIndex = 0;
  bool _isLoading = true;
  bool _isGameDayCanceled = false;
  bool _hasGames = true;
  bool _hasNews = true;
  DateTime _currentDateObj = DateTime(2025, 4, 8); // 기본 날짜는 4월 8일(화)
  String _currentDateStr = '2025. 04. 08(화)';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 데이터를 로드합니다
  Future<void> _loadData() async {
    // 실제 환경에서는 비동기 데이터 로딩 구현
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isGameDayCanceled = _gameRepository.isDateGameCanceled(
          _currentDateObj,
        );
        _hasGames = _gameRepository.hasGamesForDate(_currentDateObj);
        _hasNews = _newsRepository.hasNewsForDate(_currentDateObj);
        _isLoading = false;
      });
    });
  }

  /// 날짜를 변경합니다
  void _changeDate(DateTime newDate) {
    // 날짜 포맷팅 (요일 표시 포함)
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayIndex = newDate.weekday - 1; // 0 based index for weekdays
    final weekday = weekdays[weekdayIndex];

    setState(() {
      _currentDateObj = newDate;
      _currentDateStr =
          '${newDate.year}. ${newDate.month.toString().padLeft(2, '0')}. ${newDate.day.toString().padLeft(2, '0')}($weekday)';
      _isGameDayCanceled = _gameRepository.isDateGameCanceled(_currentDateObj);
      _hasGames = _gameRepository.hasGamesForDate(_currentDateObj);
      _hasNews = _newsRepository.hasNewsForDate(_currentDateObj);
    });
  }

  /// 테스트 버튼 동작
  void _onTestButtonPressed() {
    // 4월 7일(월) - 경기 없는 날
    if (_currentDateObj.day == 8) {
      _changeDate(DateTime(2025, 4, 7));
    }
    // 4월 13일(일) - 우천 취소
    else if (_currentDateObj.day == 7) {
      _changeDate(DateTime(2025, 4, 13));
    }
    // 원래 날짜로 복귀
    else {
      _changeDate(DateTime(2025, 4, 8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? _buildLoadingView()
              : IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildHomeTab(),
                  _buildRecordTab(),
                  _buildScheduleTab(),
                ],
              ),
      bottomNavigationBar: FooterComponent(
        currentIndex: _currentTabIndex,
        onTabChanged: _handleTabChanged,
      ),
      // 기록 탭이 아닐 때만 테스트용 FloatingActionButton 표시
      floatingActionButton:
          _currentTabIndex != 1
              ? FloatingActionButton(
                onPressed: _onTestButtonPressed,
                tooltip: '테스트 날짜 변경',
                child: const Icon(Icons.calendar_today),
              )
              : null,
    );
  }

  /// 로딩 화면
  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  /// 홈 탭
  Widget _buildHomeTab() {
    final nickname = _userRepository.getUserNickname();
    final favoriteTeam = _userRepository.getFavoriteTeam();
    final teamLogoImage = _userRepository.getTeamLogoImage();
    final userStats = _userRepository.getUserStats();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              HeaderComponent(nickname: nickname),
              const SizedBox(height: 32),
              ProfileComponent(
                nickname: nickname,
                favoriteTeam: favoriteTeam,
                teamLogoImage: teamLogoImage,
                level: _userRepository.getUserLevel(),
                isPremium: _userRepository.isPremiumUser(),
              ),
              const SizedBox(height: 32),
              RecordStatsComponent(
                totalGames: userStats['totalGames'] ?? 0,
                wins: userStats['wins'] ?? 0,
                draws: userStats['draws'] ?? 0,
                losses: userStats['losses'] ?? 0,
                winRate: userStats['winRate'] ?? 0.0,
              ),
              const SizedBox(height: 32),
              GamesTodayComponent(
                games:
                    _hasGames
                        ? _gameRepository.getGamesByDate(_currentDateObj)
                        : [],
                date: _currentDateStr,
                isCanceled: _isGameDayCanceled,
                onGameTapped: _handleGameTapped,
              ),
              const SizedBox(height: 32),
              NewsComponent(
                newsItems:
                    _hasNews
                        ? _newsRepository.getNewsByDate(_currentDateObj)
                        : [],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 기록 탭
  Widget _buildRecordTab() {
    return const RecordListPage();
  }

  /// 일정 탭
  Widget _buildScheduleTab() {
    return const Center(
      child: Text(
        '일정 탭 준비 중...',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 게임 탭 이벤트 핸들러
  void _handleGameTapped(game) {
    // 여기에 게임 탭 이벤트 처리 로직 구현
    print('Game tapped: ${game.team1} vs ${game.team2}');
  }

  /// 하단 탭 변경 이벤트 핸들러
  void _handleTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }
}
