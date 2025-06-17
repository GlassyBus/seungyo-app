import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
import 'package:seungyo/view/record/record_detail_screen.dart';
import 'package:seungyo/view/record/record_screen.dart';
import 'package:seungyo/view/schedules/schedules_screen.dart';
import 'package:seungyo/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/game_record.dart';
import '../../models/game_schedule.dart';
import '../../models/team.dart';
import '../../models/user_profile.dart';
import '../../services/news_service.dart';
import '../../services/record_service.dart';
import '../../services/schedule_service.dart';
import '../../services/user_service.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../auth/user_profile_screen.dart';
import 'components/profile_component.dart';
import 'widgets/news_section.dart';
import 'widgets/stats_section.dart';
import 'widgets/today_games_section.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const MainScreen({Key? key, this.onThemeModeChanged, this.currentThemeMode = ThemeMode.system}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<GameRecord> _allRecords = [];
  List<GameSchedule> _todayGames = [];
  List<Map<String, dynamic>> _newsItems = [];
  bool _isLoading = true;
  int _currentTabIndex = 0; // 현재 선택된 탭 인덱스

  // 통계 데이터 (경기 취소나 동점 제외)
  int _totalGames = 0; // 총 직관 기록
  int _winCount = 0; // 승리 기록
  int _drawCount = 0; // 무승부 기록 (표시용)
  int _loseCount = 0; // 패배 기록

  final UserService _userService = UserService();
  final ScheduleService _scheduleService = ScheduleService();
  final NewsService _newsService = NewsService();
  UserProfile? _userProfile;
  Team? _favoriteTeam;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHomeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    print('MainScreen: Starting to load home data...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('MainScreen: Loading records from database...');
      final recordService = RecordService();
      final allRecords = await recordService.getAllRecords();
      print('MainScreen: Loaded ${allRecords.length} records');

      print('MainScreen: Loading user profile...');
      final userProfile = await _userService.getUserProfile();
      final favoriteTeam = await _userService.getUserFavoriteTeam();
      print(
        'MainScreen: User profile loaded - Nickname: ${userProfile.nickname}, Favorite team: ${favoriteTeam?.name}',
      );

      // 오늘의 경기 데이터 로드
      print('MainScreen: Loading today\'s games...');
      final today = DateTime.now();
      final todayGames = await _scheduleService.getSchedulesByDate(today);
      print('MainScreen: Loaded ${todayGames.length} today\'s games');

      // 통계 계산 (경기 취소나 동점 제외)
      print('MainScreen: Calculating statistics...');
      final validRecords =
          allRecords.where((record) {
            return record.result == GameResult.win ||
                record.result == GameResult.lose ||
                record.result == GameResult.draw;
          }).toList();

      final totalGames = validRecords.length;
      final winCount = validRecords.where((record) => record.result == GameResult.win).length;
      final drawCount = validRecords.where((record) => record.result == GameResult.draw).length;
      final loseCount = validRecords.where((record) => record.result == GameResult.lose).length;

      print('MainScreen: Statistics - Total: $totalGames, Win: $winCount, Draw: $drawCount, Lose: $loseCount');

      // 뉴스 데이터 로드 (응원 구단 키워드 포함)
      print('MainScreen: Loading news...');
      final teamKeyword = favoriteTeam?.name ?? '두산';
      final newsItems = await _newsService.getNewsByKeyword(teamKeyword, limit: 4);
      print('MainScreen: Loaded ${newsItems.length} news items');

      setState(() {
        _allRecords = allRecords;
        _todayGames = todayGames;
        _totalGames = totalGames;
        _winCount = winCount;
        _drawCount = drawCount;
        _loseCount = loseCount;
        _userProfile = userProfile;
        _favoriteTeam = favoriteTeam;
        _newsItems = newsItems;
      });

      print('MainScreen: Home data loaded successfully');
    } catch (e) {
      print('MainScreen: Error loading home data: $e');
      print('MainScreen: Error stack trace: ${StackTrace.current}');

      // 오류 발생 시에도 기본값으로라도 UI 표시
      setState(() {
        _allRecords = [];
        _todayGames = [];
        _totalGames = 0;
        _winCount = 0;
        _drawCount = 0;
        _loseCount = 0;
        _newsItems = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCurrentAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: _currentTabIndex, onTabChanged: _onTabChanged),
    );
  }

  PreferredSizeWidget? _buildCurrentAppBar() {
    switch (_currentTabIndex) {
      case 0: // 홈 탭
        return const CustomAppBar(title: '홈');
      case 1: // 기록 탭
        return CustomAppBar(
          title: '직관 기록',
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF09004C), size: 24),
              onPressed: _navigateToAddRecord,
            ),
          ],
        );
      case 2: // 일정 탭
        return const CustomAppBar(title: '경기 일정');
      default:
        return const CustomAppBar(title: '홈');
    }
  }

  void _onTabChanged(int index) {
    // 이미 같은 탭이 선택되어 있으면 무시
    if (_currentTabIndex == index) {
      print('MainScreen: Same tab selected, ignoring...');
      return;
    }

    setState(() {
      _currentTabIndex = index;
    });

    // 기록 탭에서 다른 탭으로 이동할 때는 새로고침하지 않음
    // 홈 탭으로 돌아올 때만 새로고침 (다른 탭에서 변경사항이 있을 수 있음)
    if (index == 0) {
      print('MainScreen: Switched to home tab, refreshing data...');
      _loadHomeData();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF09004C)),
          SizedBox(height: 16),
          Text('데이터를 불러오는 중...', style: TextStyle(color: Color(0xFF7E8695), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        _buildHomeContent(), // 홈 탭
        _buildRecordsContent(), // 기록 탭
        _buildScheduleContent(), // 일정 탭
      ],
    );
  }

  Widget _buildHomeContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadHomeData,
        color: const Color(0xFF09004C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 프로필 섹션
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: ProfileComponent(
                    userProfile: _userProfile,
                    favoriteTeam: _favoriteTeam,
                    onMoreTap: _navigateToUserProfile,
                  ),
                ),
                // Divider
                Container(height: 8, color: const Color(0xFFF7F8FB)),
                // 통계 섹션
                StatsSection(
                  totalGames: _totalGames,
                  winCount: _winCount,
                  drawCount: _drawCount,
                  loseCount: _loseCount,
                ),
                // Divider
                Container(height: 8, color: const Color(0xFFF7F8FB)),
                // 오늘의 경기 섹션
                TodayGamesSection(todayGames: _todayGames, onGameEditTap: _handleRecordButtonTap),
                // Divider
                Container(height: 8, color: const Color(0xFFF7F8FB)),
                // 최근 소식 섹션
                NewsSection(newsItems: _newsItems, onNewsUrlTap: _openNewsUrl),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsContent() {
    return RecordListPage(
      key: ValueKey(_currentTabIndex == 1 ? DateTime.now().millisecondsSinceEpoch : 0),
      onRecordChanged: () {
        // 기록이 변경되었을 때 홈 데이터 새로고침
        print('MainScreen: Record changed, refreshing home data...');
        _loadHomeData();
      },
    );
  }

  Widget _buildScheduleContent() {
    return const SchedulePage();
  }

  // 직관 기록 버튼 탭 처리
  Future<void> _handleRecordButtonTap(GameSchedule game) async {
    HapticFeedback.lightImpact();

    // 해당 경기에 대한 기록이 이미 있는지 확인
    final existingRecord =
        _allRecords.where((record) {
          final recordDate = record.dateTime;
          final gameDate = game.dateTime;

          return recordDate.year == gameDate.year &&
              recordDate.month == gameDate.month &&
              recordDate.day == gameDate.day &&
              record.homeTeam == game.homeTeam &&
              record.awayTeam == game.awayTeam;
        }).firstOrNull;

    if (existingRecord != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RecordDetailPage(game: existingRecord)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecordScreen()));
    }
  }

  // 뉴스 링크 열기
  Future<void> _openNewsUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // URL을 열 수 없는 경우 무시
    }
  }

  // 네비게이션 메서드들
  void _navigateToAddRecord() async {
    HapticFeedback.lightImpact();
    print('MainScreen: Navigating to CreateRecordScreen...');

    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecordScreen()));

    // 기록 추가 후 홈 데이터 새로고침
    if (result == true) {
      print('MainScreen: Record added successfully, refreshing home data...');
      await _loadHomeData();

      // 기록 탭이 현재 탭이면 해당 데이터도 새로고침
      if (_currentTabIndex == 1) {
        print('MainScreen: Currently on records tab, triggering refresh...');
        setState(() {
          // setState를 호출하여 RecordListPage가 새로고침되도록 함
        });
      }
    }
  }

  void _navigateToUserProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage())).then((hasChanges) {
      // 변경사항이 있으면 홈 데이터 새로고침
      if (hasChanges == true) {
        _loadHomeData();
      }
    });
  }

  void _showNotificationSettings() {
    // TODO: 알림 설정 모달 표시
  }
}
