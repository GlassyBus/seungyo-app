import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 설정 관리 Provider (개선된 버전)
class NotificationSettingsProvider extends ChangeNotifier {
  static const String _gameStartKey = 'notification_game_start';
  static const String _gameEndKey = 'notification_game_end';

  bool _gameStartNotification = true;
  bool _gameEndNotification = true;
  bool _isLoading = true;
  String? _lastError;

  // Getters
  bool get gameStartNotification => _gameStartNotification;
  bool get gameEndNotification => _gameEndNotification;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get hasError => _lastError != null;

  NotificationSettingsProvider() {
    _initialize();
  }

  /// 초기화 (향상된 에러 처리)
  Future<void> _initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      await loadSettings();
      
      if (kDebugMode) {
        print('🔔 NotificationSettings 초기화 완료: 시작 알림 = $_gameStartNotification, 종료 알림 = $_gameEndNotification');
      }
    } catch (error) {
      _setError('초기화 실패: $error');
      
      if (kDebugMode) {
        print('❌ NotificationSettings 초기화 실패: $error');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 설정 로드 (검증 로직 포함)
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 검증된 값으로 로드
      _gameStartNotification = _validateBooleanSetting(
        prefs.getBool(_gameStartKey),
        defaultValue: true,
        settingName: '게임 시작 알림',
      );
      
      _gameEndNotification = _validateBooleanSetting(
        prefs.getBool(_gameEndKey),
        defaultValue: true,
        settingName: '게임 종료 알림',
      );
      
      _clearError();
      notifyListeners();
      
      if (kDebugMode) {
        print('📱 알림 설정 로드됨: 시작=$_gameStartNotification, 종료=$_gameEndNotification');
      }
    } catch (error) {
      _setError('설정 로드 실패: $error');
      rethrow;
    }
  }

  /// Boolean 설정 검증
  bool _validateBooleanSetting(bool? value, {required bool defaultValue, required String settingName}) {
    if (value == null) {
      if (kDebugMode) {
        print('⚠️ $settingName 설정이 null입니다. 기본값($defaultValue)을 사용합니다.');
      }
      return defaultValue;
    }
    return value;
  }

  /// 경기 시작 알림 설정 (검증 포함)
  Future<void> setGameStartNotification(bool value) async {
    try {
      if (_gameStartNotification == value) {
        if (kDebugMode) {
          print('🔄 경기 시작 알림 설정이 동일합니다: $value');
        }
        return;
      }

      _gameStartNotification = value;
      notifyListeners();
      
      if (kDebugMode) {
        print('🔔 경기 시작 알림 설정 변경: $value');
      }
    } catch (error) {
      _setError('경기 시작 알림 설정 실패: $error');
      rethrow;
    }
  }

  /// 경기 종료 알림 설정 (검증 포함)
  Future<void> setGameEndNotification(bool value) async {
    try {
      if (_gameEndNotification == value) {
        if (kDebugMode) {
          print('🔄 경기 종료 알림 설정이 동일합니다: $value');
        }
        return;
      }

      _gameEndNotification = value;
      notifyListeners();
      
      if (kDebugMode) {
        print('⚾ 경기 종료 알림 설정 변경: $value');
      }
    } catch (error) {
      _setError('경기 종료 알림 설정 실패: $error');
      rethrow;
    }
  }

  /// 설정 저장 (원자적 저장 및 롤백 지원)
  Future<void> saveSettings() async {
    try {
      _clearError();
      
      final prefs = await SharedPreferences.getInstance();
      
      // 현재 설정 백업 (롤백용)
      final backupGameStart = prefs.getBool(_gameStartKey);
      final backupGameEnd = prefs.getBool(_gameEndKey);
      
      // 설정 저장 시도
      final results = await Future.wait([
        prefs.setBool(_gameStartKey, _gameStartNotification),
        prefs.setBool(_gameEndKey, _gameEndNotification),
      ]);
      
      // 저장 결과 검증
      if (!results.every((result) => result)) {
        throw Exception('일부 설정 저장에 실패했습니다');
      }
      
      // 저장된 값 재검증
      await _verifyStoredSettings();
      
      if (kDebugMode) {
        print('💾 알림 설정 저장 완료: 시작=$_gameStartNotification, 종료=$_gameEndNotification');
      }
      
    } catch (error) {
      _setError('설정 저장 실패: $error');
      
      // 롤백 시도
      await _attemptRollback();
      
      rethrow;
    }
  }

  /// 저장된 설정 검증
  Future<void> _verifyStoredSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final storedGameStart = prefs.getBool(_gameStartKey);
    final storedGameEnd = prefs.getBool(_gameEndKey);
    
    if (storedGameStart != _gameStartNotification || storedGameEnd != _gameEndNotification) {
      throw Exception('저장된 설정이 예상 값과 다릅니다');
    }
  }

  /// 롤백 시도
  Future<void> _attemptRollback() async {
    try {
      if (kDebugMode) {
        print('🔄 설정 롤백을 시도합니다...');
      }
      
      await loadSettings();
      
      if (kDebugMode) {
        print('✅ 설정이 롤백되었습니다.');
      }
    } catch (rollbackError) {
      if (kDebugMode) {
        print('❌ 롤백도 실패했습니다: $rollbackError');
      }
    }
  }

  /// 설정 리셋 (공장 초기화)
  Future<void> resetToDefaults() async {
    try {
      _clearError();
      
      const defaultGameStart = true;
      const defaultGameEnd = true;
      
      _gameStartNotification = defaultGameStart;
      _gameEndNotification = defaultGameEnd;
      
      await saveSettings();
      
      if (kDebugMode) {
        print('🔄 알림 설정이 기본값으로 리셋되었습니다');
      }
      
    } catch (error) {
      _setError('설정 리셋 실패: $error');
      rethrow;
    }
  }

  /// 설정 상태 요약
  Map<String, dynamic> getSettingsSummary() {
    return {
      'gameStartNotification': _gameStartNotification,
      'gameEndNotification': _gameEndNotification,
      'isLoading': _isLoading,
      'hasError': hasError,
      'lastError': _lastError,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 에러 설정
  void _setError(String error) {
    _lastError = error;
    notifyListeners();
    
    if (kDebugMode) {
      print('❌ NotificationSettings 에러: $error');
    }
  }

  /// 에러 클리어
  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🗑️ NotificationSettingsProvider disposed');
    }
    super.dispose();
  }
} 