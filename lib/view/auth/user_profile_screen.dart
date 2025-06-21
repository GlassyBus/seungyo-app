import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/team.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../theme/theme.dart';
import 'widgets/select_team_view.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final UserService _userService = UserService();

  UserProfile? _userProfile;
  Team? _favoriteTeam;
  bool _isLoading = true;
  bool _isSaving = false;
  String _originalNickname = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    setState(() {
      // 텍스트 변경 시 UI 업데이트
    });
  }

  Future<void> _loadUserData() async {
    if (kDebugMode) if (kDebugMode) print('UserProfilePage: Loading user data...');
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userService.getUserProfile();
      final team = await _userService.getUserFavoriteTeam();

      if (kDebugMode) if (kDebugMode) print('UserProfilePage: Profile loaded - Nickname: ${profile.nickname}');
      if (kDebugMode) if (kDebugMode) {
        print(
        'UserProfilePage: Team loaded - Name: ${team?.name}, Logo: ${team?.logo}',
      );
      }

      setState(() {
        _userProfile = profile;
        _favoriteTeam = team;
        _originalNickname = profile.nickname;
        _nicknameController.text = profile.nickname;
      });
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('UserProfilePage: Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_userProfile == null) return;

    final newNickname = _nicknameController.text.trim();

    // 빈 닉네임 체크
    if (newNickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile = await _userService.updateNickname(newNickname);

      setState(() {
        _userProfile = updatedProfile;
        _originalNickname = newNickname;
        _hasChanges = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('변경사항이 저장되었습니다')));

      // 저장 완료 후 화면 닫기
      if (mounted) {
        Navigator.of(context).pop(_hasChanges);
      }
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error saving profile: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToTeamSelection() async {
    final selectedTeam = await Navigator.push<Team>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectTeamView(
              isStandalone: true,
              currentTeamId: _favoriteTeam?.id,
              title: '응원 구단 변경',
            ),
      ),
    );

    if (selectedTeam != null) {
      try {
        await _userService.updateFavoriteTeam(selectedTeam.id);
        await _loadUserData(); // 데이터 새로고침

        setState(() {
          _hasChanges = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('응원 구단이 ${selectedTeam.name}로 변경되었습니다')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('구단 변경 중 오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_hasChanges);
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text('정보 확인', style: textTheme.titleLarge),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).pop(_hasChanges);
            },
          ),
        ),
        body:
            _isLoading
                ? _buildLoadingState()
                : _buildContent(colorScheme, textTheme),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '사용자 정보를 불러오는 중...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 0), // 피그마 디자인에 맞는 패딩
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFavoriteTeamSection(colorScheme, textTheme),
                const SizedBox(height: 25), // 피그마 디자인에 맞는 간격
                _buildNicknameSection(colorScheme, textTheme),
              ],
            ),
          ),
        ),
        _buildBottomButton(colorScheme, textTheme),
      ],
    );
  }

  Widget _buildFavoriteTeamSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '응원 구단',
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF7E8695),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10), // 피그마 디자인에 맞는 간격
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE6EAF2), // 피그마 디자인 테두리 색상
                      width: 1.33,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(9.6), // 피그마에서 이미지 위치에 맞는 패딩
                      child: _buildTeamLogo(),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // 피그마 디자인 간격
                Text(
                  _favoriteTeam?.name ?? '팀을 선택해주세요',
                  style: const TextStyle(
                    color: Color(0xFF100F21),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'KBO',
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _navigateToTeamSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF09004C),
                // 피그마 디자인 배경색
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // 피그마 디자인 borderRadius
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                // 피그마 디자인 패딩
                elevation: 0,
              ),
              child: const Text(
                '변경',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'KBO',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNicknameSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '닉네임',
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF7E8695),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 56, // 피그마 디자인에 맞는 고정 높이
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB), // 피그마 디자인 배경색
            borderRadius: BorderRadius.circular(12), // 피그마 디자인 borderRadius
            border: Border.all(
              color: const Color(0xFFE6EAF2),
              width: 1,
            ), // 피그마 디자인 테두리
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '닉네임을 입력해주세요',
                    hintStyle: TextStyle(
                      color: Color(0xFF7E8695),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    counterText: '', // 글자 수 카운터 숨기기
                  ),
                  style: const TextStyle(
                    color: Color(0xFF100F21),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'KBO',
                  ),
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(ColorScheme colorScheme, TextTheme textTheme) {
    final hasChanges = _nicknameController.text.trim() != _originalNickname;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), // 피그마 디자인에 맞는 패딩
      child: SizedBox(
        width: double.infinity,
        height: 48, // 피그마 디자인에 맞는 높이
        child: ElevatedButton(
          onPressed: hasChanges && !_isSaving ? _saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF09004C),
            // 피그마 디자인 배경색
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFD1D9E8),
            // 비활성화 상태 색상
            disabledForegroundColor: const Color(0xFF7E8695),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 피그마 디자인 borderRadius
            ),
            elevation: 0,
          ),
          child:
              _isSaving
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    '변경 완료',
                    style: TextStyle(
                      color:
                          hasChanges ? Colors.white : const Color(0xFF7E8695),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'KBO',
                    ),
                  ),
        ),
      ),
    );
  }

  /// 팀 로고 빌드
  Widget _buildTeamLogo() {
    if (_favoriteTeam?.logo != null && _favoriteTeam!.logo!.isNotEmpty) {
      if (_favoriteTeam!.logo!.startsWith('assets/')) {
        // Assets 이미지
        return Image.asset(
          _favoriteTeam!.logo!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) if (kDebugMode) {
              print(
              'UserProfilePage: Error loading team logo: ${_favoriteTeam!.logo}',
            );
            }
            return _buildFallbackLogo();
          },
        );
      } else {
        // 이모지나 다른 텍스트
        return Center(
          child: Text(
            _favoriteTeam!.logo!,
            style: const TextStyle(fontSize: 32),
          ),
        );
      }
    } else {
      return _buildFallbackLogo();
    }
  }

  /// 대체 로고 (팀명 첫 글자 또는 기본 아이콘)
  Widget _buildFallbackLogo() {
    if (_favoriteTeam?.shortName != null &&
        _favoriteTeam!.shortName.isNotEmpty) {
      return Center(
        child: Text(
          _favoriteTeam!.shortName.substring(0, 1),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.sports_baseball, size: 32, color: AppColors.navy),
      );
    }
  }
}
