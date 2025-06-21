import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/game_schedule.dart';
import '../providers/notification_settings_provider.dart';
import 'schedule_service.dart';
import 'user_service.dart';
import '../view/record/create_record_screen.dart';
import '../main.dart' show navigatorKey;

/// 로컬 푸시 알림 관리 서비스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    try {
      // Android 설정
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS 설정
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Android 알림 채널 생성
      await _createNotificationChannel();

      // 알림 권한 요청
      await _requestPermissions();

      if (kDebugMode) {
        if (kDebugMode) print('📱 알림 서비스 초기화 완료');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 서비스 초기화 실패: $error');
      }
      rethrow;
    }
  }

  /// Android 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    const androidNotificationChannel = AndroidNotificationChannel(
      'seungyo_game_channel', // 채널 ID
      '승요 경기 알림', // 채널 이름
      description: '승요 앱 경기 일정 관련 알림',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        androidNotificationChannel,
      );

      if (kDebugMode) {
        if (kDebugMode) print('📱 Android 알림 채널 생성 완료: seungyo_game_channel');
      }
    }
  }

  /// 알림 권한 확인
  Future<bool> checkNotificationPermission() async {
    try {
      // Android의 경우
      if (Theme.of(navigatorKey.currentContext!).platform ==
          TargetPlatform.android) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }

      // iOS의 경우
      final iosImpl =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImpl != null) {
        final result = await iosImpl.checkPermissions();
        return (result?.isEnabled ?? false);
      }

      return false;
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 권한 확인 실패: $error');
      }
      return false;
    }
  }

  /// 알림 권한 요청 및 설정 화면 이동
  Future<bool> requestNotificationPermission({
    bool showSettingsIfDenied = true,
  }) async {
    try {
      // 현재 권한 상태 확인
      bool hasPermission = await checkNotificationPermission();

      if (hasPermission) {
        return true;
      }

      // Android의 경우
      if (Theme.of(navigatorKey.currentContext!).platform ==
          TargetPlatform.android) {
        final status = await Permission.notification.request();

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied && showSettingsIfDenied) {
          return await _showPermissionSettingsDialog();
        }
      }

      // iOS의 경우
      final iosImpl =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImpl != null) {
        final result = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        if (result == true) {
          return true;
        } else if (showSettingsIfDenied) {
          return await _showPermissionSettingsDialog();
        }
      }

      return false;
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 권한 요청 실패: $error');
      }
      return false;
    }
  }

  /// 권한 설정 화면으로 이동하는 다이얼로그 표시
  Future<bool> _showPermissionSettingsDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '알림 권한이 필요합니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF09004C),
            ),
          ),
          content: const Text(
            '경기 시작 및 종료 알림을 받으려면\n알림 권한을 허용해주세요.\n\n설정 화면에서 알림을 활성화할 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF100F21),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF7E8695),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await openAppSettings();
              },
              child: const Text(
                '설정으로 이동',
                style: TextStyle(
                  color: Color(0xFF09004C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 알림 권한 요청 (기존 메서드 수정)
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// 알림 탭 이벤트 처리
  void _onNotificationTapped(NotificationResponse response) async {
    if (kDebugMode) {
      if (kDebugMode) print('🔔 알림 탭됨: ${response.payload}');
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 네비게이션 컨텍스트를 찾을 수 없습니다');
      }
      return;
    }

    try {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) {
        if (kDebugMode) {
          if (kDebugMode) print('❌ 알림 페이로드가 비어있습니다');
        }
        return;
      }

      // 페이로드 파싱: "gameId:123,type:game_start"
      final parts = payload.split(',');
      if (parts.length != 2) {
        if (kDebugMode) {
          if (kDebugMode) print('❌ 잘못된 페이로드 형식: $payload');
        }
        return;
      }

      final gameIdPart = parts[0].split(':');
      final typePart = parts[1].split(':');

      if (gameIdPart.length != 2 || typePart.length != 2) {
        if (kDebugMode) {
          if (kDebugMode) print('❌ 페이로드 파싱 실패: $payload');
        }
        return;
      }

      final gameId = int.tryParse(gameIdPart[1]);
      final notificationType = typePart[1];

      if (gameId == null) {
        if (kDebugMode) {
          if (kDebugMode) print('❌ 게임 ID 파싱 실패: ${gameIdPart[1]}');
        }
        return;
      }

      if (kDebugMode) {
        if (kDebugMode) print('📱 알림 처리: 게임 ID=$gameId, 타입=$notificationType');
      }

      // 게임 정보 가져오기
      final scheduleService = ScheduleService();
      final allSchedules = await scheduleService.getAllSchedules();
      final gameSchedule = allSchedules.firstWhere(
        (schedule) => schedule.id == gameId,
        orElse: () => throw Exception('게임을 찾을 수 없습니다'),
      );

      // 알림 타입에 따른 네비게이션
      await _navigateBasedOnNotificationType(
        notificationType,
        gameSchedule,
        context,
      );
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 탭 처리 실패: $error');
      }

      // 에러 발생 시 기본적으로 일정 화면으로 이동
      await _navigateToScheduleTab(context);
    }
  }

  /// 알림 타입에 따른 네비게이션 처리
  Future<void> _navigateBasedOnNotificationType(
    String notificationType,
    GameSchedule gameSchedule,
    BuildContext context,
  ) async {
    switch (notificationType) {
      case 'game_start':
        // 경기 시작 알림: 일정 화면으로 이동
        if (kDebugMode) {
          if (kDebugMode) print('📅 경기 시작 알림 - 일정 화면으로 이동');
        }
        await _navigateToScheduleTab(context);
        break;

      case 'game_end':
        // 경기 종료 알림: 직관 기록 작성 화면으로 이동
        if (kDebugMode) {
          if (kDebugMode) print('✍️ 경기 종료 알림 - 직관 기록 작성 화면으로 이동');
        }
        await _navigateToCreateRecord(context, gameSchedule);
        break;

      default:
        if (kDebugMode) {
          if (kDebugMode) print('⚠️ 알 수 없는 알림 타입: $notificationType');
        }
        await _navigateToScheduleTab(context);
        break;
    }
  }

  /// 일정 화면으로 이동 (탭 변경)
  Future<void> _navigateToScheduleTab(BuildContext context) async {
    try {
      // 메인 화면으로 돌아가기 (모든 다른 화면들을 제거)
      Navigator.of(context).popUntil((route) => route.isFirst);

      if (kDebugMode) {
        if (kDebugMode) print('📅 일정 화면으로 네비게이션 완료 (메인 화면으로 복귀)');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 일정 화면 이동 실패: $error');
      }
    }
  }

  /// 직관 기록 작성 화면으로 이동
  Future<void> _navigateToCreateRecord(
    BuildContext context,
    GameSchedule gameSchedule,
  ) async {
    try {
      // 메인 화면으로 돌아간 후 직관 기록 작성 화면으로 이동
      Navigator.of(context).popUntil((route) => route.isFirst);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateRecordScreen(gameSchedule: gameSchedule),
        ),
      );

      if (kDebugMode) {
        if (kDebugMode) print('✍️ 직관 기록 작성 화면으로 네비게이션 완료');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 직관 기록 작성 화면 이동 실패: $error');
      }

      // 실패 시 일정 화면으로 대체 이동
      await _navigateToScheduleTab(context);
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();

      if (kDebugMode) {
        if (kDebugMode) print('🔕 모든 알림이 취소되었습니다');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 취소 실패: $error');
      }
      rethrow;
    }
  }

  /// 팀 이름으로 팀 ID 찾기 (CreateRecordScreen에서 가져온 로직)
  String? _getTeamIdByName(String teamName) {
    // 팀 이름 매핑 (team_data.dart의 실제 코드에 맞춤)
    const teamNameMapping = {
      '두산': 'bears', // code: "두산"
      '키움': 'heroes', // code: "키움"
      'SSG': 'landers', // code: "SSG"
      'LG': 'twins', // code: "LG"
      '삼성': 'lions', // code: "삼성"
      '한화': 'eagles', // code: "한화"
      'NC': 'dinos', // code: "NC"
      '롯데': 'giants', // code: "롯데"
      'KIA': 'tigers', // code: "KIA"
      'KT': 'wiz', // code: "KT"
    };

    return teamNameMapping[teamName];
  }

  /// 사용자의 응원팀인지 확인 (팀 ID 매칭 개선)
  bool _isUserFavoriteTeamGame(GameSchedule schedule, String favoriteTeamId) {
    // 1. 직접 팀 ID 비교 (favoriteTeamId와 일치)
    final homeTeamId = _getTeamIdByName(schedule.homeTeam);
    final awayTeamId = _getTeamIdByName(schedule.awayTeam);

    if (homeTeamId == favoriteTeamId || awayTeamId == favoriteTeamId) {
      return true;
    }

    // 2. 팀 이름 직접 비교 (fallback)
    if (schedule.homeTeam.contains('LG') || schedule.awayTeam.contains('LG')) {
      return favoriteTeamId == 'twins'; // LG 트윈스
    }

    return false;
  }

  /// 알림 설정에 따라 모든 알림 업데이트
  Future<void> updateNotificationSettings(List<GameSchedule> schedules) async {
    try {
      final settingsProvider = NotificationSettingsProvider();
      await settingsProvider.loadSettings();

      // 기존 알림 모두 취소
      await cancelAllNotifications();

      // 사용자의 응원팀 확인
      final userService = UserService();
      final favoriteTeam = await userService.getUserFavoriteTeam();

      if (favoriteTeam == null) {
        if (kDebugMode) {
          if (kDebugMode) print('⚠️ 사용자 응원팀 정보를 찾을 수 없어 알림 설정을 건너뜁니다.');
        }
        return;
      }

      // 개선된 응원팀 경기 필터링
      final favoriteTeamSchedules =
          schedules.where((schedule) {
            return _isUserFavoriteTeamGame(schedule, favoriteTeam.id);
          }).toList();

      if (kDebugMode) {
        if (kDebugMode) print(
          '📱 전체 ${schedules.length}개 경기 중 응원팀(${favoriteTeam.name}, ID: ${favoriteTeam.id}) 경기: ${favoriteTeamSchedules.length}개',
        );

        // 필터링된 경기들 상세 로그
        for (final schedule in favoriteTeamSchedules) {
          if (kDebugMode) print(
            '   ✅ ${schedule.homeTeam} vs ${schedule.awayTeam} (홈: ${_getTeamIdByName(schedule.homeTeam)}, 원정: ${_getTeamIdByName(schedule.awayTeam)})',
          );
        }
      }

      int scheduledCount = 0;
      // 설정에 따라 새로운 알림 스케줄링
      for (final schedule in favoriteTeamSchedules) {
        final wasScheduled = await scheduleGameNotifications(
          schedule,
          enableStartNotification: settingsProvider.gameStartNotification,
          enableEndNotification: settingsProvider.gameEndNotification,
        );
        if (wasScheduled) scheduledCount++;
      }

      if (kDebugMode) {
        if (kDebugMode) print(
          '📱 응원팀 ${favoriteTeamSchedules.length}개 경기 중 ${scheduledCount}개 경기에 대한 알림 설정 완료',
        );
        if (kDebugMode) print(
          '  - 경기 시작 알림: ${settingsProvider.gameStartNotification ? '활성화' : '비활성화'}',
        );
        if (kDebugMode) print(
          '  - 경기 종료 알림: ${settingsProvider.gameEndNotification ? '활성화' : '비활성화'}',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 설정 업데이트 실패: $error');
      }
      rethrow;
    }
  }

  /// 경기별 알림 스케줄링 - 응원팀 경기만
  Future<bool> scheduleGameNotifications(
    GameSchedule schedule, {
    required bool enableStartNotification,
    required bool enableEndNotification,
  }) async {
    try {
      final now = DateTime.now();

      // 과거 경기나 진행중/완료된 경기는 스케줄링하지 않음
      if (schedule.dateTime.isBefore(now) ||
          schedule.status != GameStatus.scheduled) {
        if (kDebugMode) {
          if (kDebugMode) print(
            '⏭️ 스킵: ${schedule.homeTeam} vs ${schedule.awayTeam} (${schedule.status.displayName})',
          );
        }
        return false;
      }

      // 사용자의 응원팀 확인
      final userService = UserService();
      final favoriteTeam = await userService.getUserFavoriteTeam();

      if (favoriteTeam == null) {
        if (kDebugMode) {
          if (kDebugMode) print('⚠️ 사용자 응원팀 정보를 찾을 수 없어 알림을 스케줄링하지 않습니다.');
        }
        return false;
      }

      // 개선된 응원팀 매칭 확인
      final isUserTeamGame = _isUserFavoriteTeamGame(schedule, favoriteTeam.id);

      if (!isUserTeamGame) {
        if (kDebugMode) {
          if (kDebugMode) print(
            '🚫 응원팀(${favoriteTeam.name}, ID: ${favoriteTeam.id}) 경기가 아님: ${schedule.homeTeam} vs ${schedule.awayTeam}',
          );
          if (kDebugMode) print(
            '   홈팀 ID: ${_getTeamIdByName(schedule.homeTeam)}, 원정팀 ID: ${_getTeamIdByName(schedule.awayTeam)}',
          );
        }
        return false;
      }

      bool wasScheduled = false;

      // 경기 시작 10분 전 알림 (Figma 디자인에 맞게 수정)
      if (enableStartNotification) {
        final startNotificationTime = schedule.dateTime.subtract(
          const Duration(minutes: 10),
        );

        if (startNotificationTime.isAfter(now)) {
          await _scheduleNotification(
            id: schedule.id * 10 + 1, // 경기 시작 알림 ID
            title: '곧 시작! ⚾️',
            body:
                '${schedule.homeTeam} vs ${schedule.awayTeam} 경기 시작까지 10분 남았습니다.',
            scheduledTime: startNotificationTime,
            gameId: schedule.id,
            notificationType: 'game_start',
          );
          wasScheduled = true;

          if (kDebugMode) {
            if (kDebugMode) print(
              '🔔 응원팀 경기 시작 알림 예약: ${schedule.homeTeam} vs ${schedule.awayTeam} (${startNotificationTime})',
            );
          }
        }
      }

      // 경기 종료 후 직관 후기 요청 알림 (Figma 디자인에 맞게 수정)
      if (enableEndNotification) {
        final endNotificationTime = schedule.dateTime.add(
          const Duration(hours: 3),
        );

        if (endNotificationTime.isAfter(now)) {
          await _scheduleNotification(
            id: schedule.id * 10 + 2, // 경기 종료 알림 ID
            title: '경기 종료! ✍️',
            body: '오늘 경기, 어떠셨나요?\n당신의 직관 후기를 남겨주세요!',
            scheduledTime: endNotificationTime,
            gameId: schedule.id,
            notificationType: 'game_end',
          );
          wasScheduled = true;

          if (kDebugMode) {
            if (kDebugMode) print(
              '📝 응원팀 경기 종료 알림 예약: ${schedule.homeTeam} vs ${schedule.awayTeam} (${endNotificationTime})',
            );
          }
        }
      }

      return wasScheduled;
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 경기 알림 스케줄링 실패 (ID: ${schedule.id}): $error');
      }
      return false;
    }
  }

  /// 예약된 알림 목록 출력 (디버그용)
  Future<void> printScheduledNotifications() async {
    try {
      final pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      if (kDebugMode) {
        if (kDebugMode) print('📱 예약된 알림 목록 (${pendingNotifications.length}개):');
        for (final notification in pendingNotifications) {
          if (kDebugMode) print('  - ID: ${notification.id}, 제목: ${notification.title}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 예약된 알림 목록 조회 실패: $error');
      }
    }
  }

  /// 알림 예약
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'seungyo_game_channel', // 채널 ID
          '승요 경기 알림', // 채널 이름
          channelDescription: '승요 앱 경기 일정 관련 알림',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      if (kDebugMode) {
        if (kDebugMode) print('✅ 알림 예약 성공: ID $id');
        if (kDebugMode) print('   제목: $title');
        if (kDebugMode) print('   내용: $body');
        if (kDebugMode) print('   예약 시간: $scheduledTime');
        if (kDebugMode) print('   현재 시간: ${DateTime.now()}');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 알림 예약 실패: $error');
      }
      rethrow;
    }
  }

  /// 내부 알림 스케줄링 메서드
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required int gameId,
    required String notificationType,
  }) async {
    // Figma 디자인에 맞는 알림 채널 설정
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'seungyo_game_channel',
        '승요 경기 알림',
        channelDescription: '승요 앱 경기 일정 관련 알림',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'seungyo_game',
      ),
    );

    // 알림 페이로드에 게임 정보와 알림 타입 포함
    final payload = 'gameId:$gameId,type:$notificationType';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// DateTime을 TZDateTime으로 변환
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Seoul');
    return tz.TZDateTime.from(dateTime, location);
  }

  /// 테스트용 즉시 알림 (개발/디버그용)
  Future<void> sendTestNotification({
    String type = 'game_start', // 'game_start' 또는 'game_end'
  }) async {
    try {
      // 먼저 권한 상태 확인
      final hasPermission = await checkNotificationPermission();
      if (kDebugMode) {
        if (kDebugMode) print('🔍 현재 알림 권한 상태: $hasPermission');
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'seungyo_game_channel',
          '승요 경기 알림',
          channelDescription: '승요 앱 경기 일정 관련 알림',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          showWhen: true,
          ongoing: true,
          autoCancel: false,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'seungyo_game',
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        9999, // 테스트 알림 ID
        '🔥 지속 테스트 알림 ⚾',
        '이 알림이 보인다면 성공! (직접 닫아야 사라집니다)',
        notificationDetails,
        payload: 'gameId:999,type:$type',
      );

      if (kDebugMode) {
        if (kDebugMode) print('🧪 지속 테스트 알림 전송 완료 (ongoing=true)');
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 지속 테스트 알림 전송 실패: $error');
      }
      rethrow;
    }
  }

  /// 즉시 테스트 알림 (별칭 메서드)
  Future<void> sendImmediateTestNotification() async {
    await sendTestNotification();
  }

  /// 5초 후 테스트 알림 (지연 테스트용)
  Future<void> sendDelayedTestNotification({
    int delaySeconds = 5,
    String type = 'game_start',
  }) async {
    try {
      // 먼저 모든 예약된 알림 취소
      await _flutterLocalNotificationsPlugin.cancelAll();

      final now = DateTime.now();
      final scheduledTime = now.add(Duration(seconds: delaySeconds));

      // 한국 시간대로 강제 설정
      final location = tz.getLocation('Asia/Seoul');
      final seoulNow = tz.TZDateTime.from(now, location);
      final seoulScheduledTime = tz.TZDateTime.from(scheduledTime, location);

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'seungyo_game_channel',
          '승요 경기 알림',
          channelDescription: '승요 앱 경기 일정 관련 알림',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        9998, // 테스트 알림 ID
        '⏰ ${delaySeconds}초 후 테스트 알림',
        '정확히 ${delaySeconds}초 후에 이 알림이 와야 합니다! 🎯',
        seoulScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'gameId:999,type:$type',
      );

      // 예약 확인
      final pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      final testNotification =
          pendingNotifications.where((n) => n.id == 9998).firstOrNull;

      if (kDebugMode) {
        if (kDebugMode) print('⏰ ${delaySeconds}초 후 테스트 알림 예약 완료');
        if (kDebugMode) print('   현재 시간 (로컬): $now');
        if (kDebugMode) print('   현재 시간 (서울): $seoulNow');
        if (kDebugMode) print('   예약 시간 (로컬): $scheduledTime');
        if (kDebugMode) print('   예약 시간 (서울): $seoulScheduledTime');
        if (kDebugMode) print('   타임존: ${location.name}');
        if (kDebugMode) print('   예약된 알림 존재: ${testNotification != null}');
        if (kDebugMode) print('   전체 예약된 알림 수: ${pendingNotifications.length}');

        if (testNotification != null) {
          if (kDebugMode) print('   예약된 알림 제목: ${testNotification.title}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        if (kDebugMode) print('❌ 지연 테스트 알림 예약 실패: $error');
        if (kDebugMode) print('   에러 스택: ${StackTrace.current}');
      }
      rethrow;
    }
  }
}
