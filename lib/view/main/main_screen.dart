import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
import 'package:seungyo/view/record/record_detail_screen.dart';
import 'package:seungyo/view/record/record_screen.dart';
import 'package:seungyo/view/schedules/schedules_screen.dart';
import 'package:seungyo/view/schedules/notification_settings_screen.dart';
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
import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../auth/user_profile_screen.dart';
import 'components/profile_component.dart';
import 'widgets/news_section.dart';
import 'widgets/stats_section.dart';
import 'widgets/today_games_section.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const MainScreen({
    super.key,
    this.onThemeModeChanged,
    this.currentThemeMode = ThemeMode.system,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<GameRecord> _allRecords = [];
  List<GameSchedule> _todayGames = [];
  List<Map<String, dynamic>> _newsItems = [];
  bool _isLoading = true;
  bool _isTodayGamesLoading = true; // 오늘 경기 로딩 상태 추가
  bool _isNewsLoading = true; // 뉴스 로딩 상태 추가
  int _currentTabIndex = 0; // 현재 선택된 탭 인덱스

  // 일정 탭 새로고침을 위한 키
  Key _schedulePageKey = const ValueKey('schedule_initial');

  // 통계 데이터 (경기 취소나 동점 제외)
  int _totalGames = 0; // 총 직관 기록
  int _winCount = 0; // 승리 기록
  int _drawCount = 0; // 무승부 기록 (표시용)
  int _loseCount = 0; // 패배 기록

  // 뒤로가기 더블 탭 관련
  DateTime? _lastBackPressed;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

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
      // 🚀 1단계: 기본 데이터 먼저 로드 (빠른 표시)
      print('MainScreen: Loading basic data first...');

      final recordService = RecordService();
      final userProfile = await _userService.getUserProfile();
      final favoriteTeam = await _userService.getUserFavoriteTeam();

      // 기본 통계 계산
      final allRecords = await recordService.getAllRecords();
      final validRecords =
          allRecords.where((record) {
            return record.result == GameResult.win ||
                record.result == GameResult.lose ||
                record.result == GameResult.draw;
          }).toList();

      final totalGames = validRecords.length;
      final winCount =
          validRecords
              .where((record) => record.result == GameResult.win)
              .length;
      final drawCount =
          validRecords
              .where((record) => record.result == GameResult.draw)
              .length;
      final loseCount =
          validRecords
              .where((record) => record.result == GameResult.lose)
              .length;

      // 🎯 기본 화면 먼저 표시 (오늘 경기는 로딩 중)
      setState(() {
        _allRecords = allRecords;
        _todayGames = []; // 일단 빈 리스트
        _totalGames = totalGames;
        _winCount = winCount;
        _drawCount = drawCount;
        _loseCount = loseCount;
        _userProfile = userProfile;
        _favoriteTeam = favoriteTeam;
        _newsItems = [];
        _isLoading = false; // 🚀 메인 로딩 완료
        _isTodayGamesLoading = true; // 오늘 경기는 여전히 로딩 중
        _isNewsLoading = true; // 뉴스도 여전히 로딩 중
      });

      print(
        'MainScreen: Basic data loaded, now loading today games and news...',
      );

      // 🚀 2단계: 오늘 경기 빠르게 로드 (별도로)
      _loadTodayGamesAsync();

      // 🚀 3단계: 뉴스 데이터 백그라운드 로드
      _loadNewsAsync(favoriteTeam);

      // 🚀 4단계: 백그라운드에서 여러 달 데이터 미리 로드
      _scheduleService
          .preloadSchedules()
          .then((_) {
            if (kDebugMode) {
              print('MainScreen: 백그라운드 데이터 미리 로드 완료');
            }
          })
          .catchError((e) {
            if (kDebugMode) {
              print('MainScreen: 백그라운드 데이터 미리 로드 실패: $e');
            }
          });
    } catch (e) {
      print('MainScreen: Error loading basic data: $e');

      // 오류 발생 시에도 기본값으로라도 UI 표시
      setState(() {
        _allRecords = [];
        _todayGames = [];
        _totalGames = 0;
        _winCount = 0;
        _drawCount = 0;
        _loseCount = 0;
        _newsItems = [];
        _isLoading = false;
        _isTodayGamesLoading = false;
        _isNewsLoading = false;
      });
    }
  }

  /// 오늘 경기 비동기 로드
  Future<void> _loadTodayGamesAsync() async {
    try {
      print('MainScreen: Loading today\'s games asynchronously...');

      final todayGames = await _scheduleService.getTodayGamesQuick();

      setState(() {
        _todayGames = todayGames;
        _isTodayGamesLoading = false; // 로딩 완료
      });

      print('MainScreen: Today games loaded - ${todayGames.length} games');
    } catch (e) {
      print('MainScreen: Error loading today games: $e');
      setState(() {
        _todayGames = [];
        _isTodayGamesLoading = false; // 로딩 완료 (실패해도)
      });
    }
  }

  /// 뉴스 데이터 비동기 로드
  Future<void> _loadNewsAsync(Team? favoriteTeam) async {
    try {
      print('MainScreen: Loading news asynchronously...');

      final teamKeyword = favoriteTeam?.name ?? '두산';
      final newsItems = await _newsService.getNewsByKeyword(
        teamKeyword,
        limit: 4,
      );

      setState(() {
        _newsItems = newsItems;
        _isNewsLoading = false; // 로딩 완료
      });

      print('MainScreen: News loaded - ${newsItems.length} items');
    } catch (e) {
      print('MainScreen: Error loading news: $e');
      setState(() {
        _newsItems = [];
        _isNewsLoading = false; // 로딩 완료 (실패해도)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _handleDoubleBackPress();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildCurrentAppBar(),
        body: _isLoading ? _buildLoadingState() : _buildContent(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTabChanged: _onTabChanged,
        ),
      ),
    );
  }

  Future<bool> _handleDoubleBackPress() async {
    print('MainScreen: Back button pressed on tab $_currentTabIndex');
    final now = DateTime.now();
    const duration = Duration(seconds: 2);

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > duration) {
      // 첫 번째 뒤로가기 또는 2초가 지난 후
      print('MainScreen: First back press or timeout, showing warning');
      _lastBackPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로 버튼을 한 번 더 누르면 앱이 종료됩니다.'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF09004C),
        ),
      );
      return false; // 앱을 종료하지 않음
    } else {
      // 2초 이내에 두 번째 뒤로가기
      print('MainScreen: Second back press within 2 seconds, exiting app');
      return true; // 앱 종료
    }
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
        return CustomAppBar(
          title: '경기 일정',
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF09004C),
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        );
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
          Text(
            '데이터를 불러오는 중...',
            style: TextStyle(color: Color(0xFF7E8695), fontSize: 16),
          ),
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
                ProfileComponent(
                  profile: _userProfile,
                  team: _favoriteTeam,
                  onTap: _navigateToUserProfile,
                ),
                // Divider
                Container(height: 8, color: AppColors.gray10),
                // 통계 섹션
                StatsSection(
                  totalGames: _totalGames,
                  winCount: _winCount,
                  drawCount: _drawCount,
                  loseCount: _loseCount,
                ),
                // Divider
                Container(height: 8, color: AppColors.gray10),
                // 오늘의 경기 섹션
                TodayGamesSection(
                  todayGames: _todayGames,
                  attendedRecords: _allRecords, // 직관 기록 전달
                  onGameEditTap: _handleRecordButtonTap,
                  isLoading: _isTodayGamesLoading, // 로딩 상태 전달
                ),
                // Divider
                Container(height: 8, color: AppColors.gray10),
                // 최근 소식 섹션
                NewsSection(
                  newsItems: _newsItems,
                  onNewsUrlTap: _openNewsUrl,
                  isLoading: _isNewsLoading, // 로딩 상태 전달
                ),
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
      key: ValueKey(
        _currentTabIndex == 1 ? DateTime.now().millisecondsSinceEpoch : 0,
      ),
      onRecordChanged: () {
        // 기록이 변경되었을 때 홈 데이터와 일정 탭 새로고침
        print('MainScreen: Record changed, refreshing all data...');
        _loadHomeData();
        _refreshSchedulePage();
      },
    );
  }

  Widget _buildScheduleContent() {
    // 기록 변경이 있을 때마다 SchedulePage를 새로 생성하여 최신 데이터를 반영
    return SchedulePage(key: _schedulePageKey);
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
              record.homeTeam.name.contains(game.homeTeam) &&
              record.awayTeam.name.contains(game.awayTeam);
        }).firstOrNull;

    if (existingRecord != null) {
      // 기존 기록이 있으면 상세 화면으로 (수정이 아닌 조회)
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordDetailPage(game: existingRecord),
        ),
      );

      // 상세 화면에서 수정/삭제가 발생했으면 홈 데이터와 일정 탭 새로고침
      if (result == true) {
        print(
          'MainScreen: Record modified/deleted from detail view, refreshing all data...',
        );
        await _loadHomeData();
        _refreshSchedulePage();
      }
    } else {
      // 기존 기록이 없으면 새 기록 작성 화면으로 (경기 정보 미리 설정)
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRecordScreen(gameSchedule: game),
        ),
      );

      // 기록 추가 후 홈 데이터와 일정 탭 새로고침
      if (result == true) {
        print(
          'MainScreen: Record added from today\'s game, refreshing all data...',
        );
        await _loadHomeData();
        _refreshSchedulePage();
      }
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

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRecordScreen()),
    );

    // 기록 추가 후 홈 데이터와 일정 탭 새로고침
    if (result == true) {
      print('MainScreen: Record added successfully, refreshing all data...');
      await _loadHomeData();
      _refreshSchedulePage();

      // 기록 탭이 현재 탭이면 해당 데이터도 새로고침
      if (_currentTabIndex == 1) {
        print('MainScreen: Currently on records tab, triggering refresh...');
        setState(() {
          // setState를 호출하여 RecordListPage가 새로고침되도록 함
        });
      }
    }
  }

  /// 일정 탭 새로고침
  void _refreshSchedulePage() {
    setState(() {
      _schedulePageKey = ValueKey(
        'schedule_${DateTime.now().millisecondsSinceEpoch}',
      );
    });
    print('MainScreen: Schedule page refreshed with new key');
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    ).then((hasChanges) {
      // 변경사항이 있으면 홈 데이터 새로고침
      if (hasChanges == true) {
        _loadHomeData();
      }
    });
  }
}
