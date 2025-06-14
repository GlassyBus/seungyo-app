import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../theme/theme.dart';
import 'team_selection_screen.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userService.getUserProfile();
      final team = await _userService.getUserFavoriteTeam();

      setState(() {
        _userProfile = profile;
        _favoriteTeam = team;
        _nicknameController.text = profile.nickname;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('사용자 정보를 불러오는 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_userProfile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.updateNickname(_nicknameController.text.trim());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('변경사항이 저장되었습니다')));

      Navigator.pop(context, true); // 변경사항이 있음을 알림
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _navigateToTeamSelection() async {
    final selectedTeam = await Navigator.push<Team>(
      context,
      MaterialPageRoute(
        builder:
            (context) => TeamSelectionPage(currentTeamId: _favoriteTeam?.id),
      ),
    );

    if (selectedTeam != null) {
      try {
        await _userService.updateFavoriteTeam(selectedTeam.id);
        await _loadUserData(); // 데이터 새로고침

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('정보 확인', style: textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _buildContent(colorScheme, textTheme),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFavoriteTeamSection(colorScheme, textTheme),
                const SizedBox(height: 32),
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
          style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray10,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gray20, width: 2),
              ),
              child: Center(
                child:
                    _favoriteTeam != null
                        ? Text(
                          _favoriteTeam!.logo ?? '⚾',
                          style: const TextStyle(fontSize: 32),
                        )
                        : Icon(
                          Icons.sports_baseball,
                          size: 32,
                          color: AppColors.gray50,
                        ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                _favoriteTeam?.name ?? '팀을 선택해주세요',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _navigateToTeamSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                '변경',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
          style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray5,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray20, width: 1),
          ),
          child: TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '닉네임을 입력해주세요',
              hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.gray50),
            ),
            style: textTheme.bodyLarge,
            maxLength: 20,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) {
              return Text(
                '$currentLength/$maxLength',
                style: textTheme.bodySmall?.copyWith(color: AppColors.gray50),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(ColorScheme colorScheme, TextTheme textTheme) {
    final hasChanges =
        _userProfile != null &&
        _nicknameController.text.trim() != _userProfile!.nickname;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasChanges && !_isSaving ? _saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.gray30,
            disabledForegroundColor: AppColors.gray50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isSaving
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    '변경 완료',
                    style: textTheme.titleMedium?.copyWith(
                      color: hasChanges ? Colors.white : AppColors.gray50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}
