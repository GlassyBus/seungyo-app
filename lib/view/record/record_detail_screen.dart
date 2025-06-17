import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../models/game_record.dart';
import '../../models/team.dart' as app_models;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/database_service.dart';
import '../../services/record_service.dart';
import '../../services/image_save_service.dart';
import 'create_record_screen.dart';
import 'widgets/action_modal.dart';

class RecordDetailPage extends StatefulWidget {
  final GameRecord game;

  const RecordDetailPage({Key? key, required this.game}) : super(key: key);

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  List<app_models.Team> _teams = [];
  bool _isLoading = true;
  String? _errorMessage;
  GameRecord? _currentGame;

  static const double _imageSectionHeight = 220.0;
  static const double _sectionPadding = 20.0;
  static const double _verticalSpacing = 25.0;
  static const double _teamLogoSize = 30.0;
  static const double _heartIconSize = 60.0;
  static const double _infoRowVerticalPadding = 18.0;
  static const double _labelWidth = 60.0;

  @override
  void initState() {
    super.initState();
    _currentGame = widget.game;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final teams = await DatabaseService().getTeamsAsAppModels();

      if (mounted) {
        setState(() {
          _teams = teams;
          _isLoading = false;
        });
      }
    } catch (e) {
      // 팀 로딩 실패해도 화면은 표시하되, 팀 정보만 제한적으로 표시
      if (mounted) {
        setState(() {
          _teams = []; // 빈 리스트로 설정
          _isLoading = false;
          // 에러 메시지는 설정하지 않아서 화면이 정상 표시되도록 함
        });
      }
    }
  }

  app_models.Team? _getTeamById(String teamId) {
    return _teams.firstWhereOrNull((team) => team.id == teamId);
  }

  bool _isImageFileValid(String imagePath) {
    try {
      final file = File(imagePath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 좋아요 상태가 변경되었는지 확인
        final hasChanged =
            _currentGame != null &&
            _currentGame!.isFavorite != widget.game.isFavorite;
        Navigator.pop(context, hasChanged);
        return false; // WillPopScope가 pop을 처리했으므로 false 반환
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          // 좋아요 상태가 변경되었는지 확인
          final hasChanged =
              _currentGame != null &&
              _currentGame!.isFavorite != widget.game.isFavorite;
          Navigator.pop(context, hasChanged);
        },
      ),
      title: Text(
        '직관 기록 상세',
        style: AppTextStyles.body1.copyWith(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download, color: AppColors.black),
          onPressed: _handleDownload,
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, color: AppColors.black),
          onPressed: _showActionModal,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.gray50),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body2.copyWith(color: AppColors.gray80),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildInfoSection(),
            _buildGameInfoSection(),
            _buildCommentSection(),
            _buildMemorableGameSection(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: _imageSectionHeight,
      margin: const EdgeInsets.all(_sectionPadding),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (widget.game.photos.isEmpty) {
      return Center(
        child: Icon(Icons.image, size: 80, color: AppColors.gray50),
      );
    }

    final firstImagePath = widget.game.photos.first;

    if (!_isImageFileValid(firstImagePath)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 80, color: AppColors.gray50),
            const SizedBox(height: 8),
            Text(
              '이미지를 불러올 수 없습니다',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray80),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        ImageSaveService.saveImageToGallery(firstImagePath, context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.file(
              File(firstImagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: AppColors.gray10,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 80,
                            color: AppColors.gray50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '이미지 로드 실패',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray80,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '저장',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.game.photos.length > 1) _buildImageCountBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCountBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+${widget.game.photos.length - 1}',
          style: AppTextStyles.caption.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Column(
        children: [
          _buildInfoRow('일정', _formatDateTime(widget.game.dateTime)),
          _buildDivider(),
          const SizedBox(height: _infoRowVerticalPadding),
          _buildInfoRow('위치', widget.game.stadium.name),
          _buildDivider(),
          const SizedBox(height: _infoRowVerticalPadding),
          _buildInfoRow('좌석', widget.game.seatInfo ?? '정보 없음'),
          _buildDivider(),
          const SizedBox(height: _verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.gray20, height: 1);
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: _infoRowVerticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _labelWidth,
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              label,
              style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                value,
                style: AppTextStyles.body3.copyWith(color: AppColors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '경기 정보',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
          ),
          const SizedBox(height: 10),
          _buildGameInfoCard(),
          const SizedBox(height: 10),
          _buildGameCancelCheckbox(),
          const SizedBox(height: _verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTeamLabels(),
          _buildScoreRow(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildTeamLabels() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '응원팀',
              textAlign: TextAlign.center,
              style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
            ),
          ),
          Expanded(
            child: Text(
              '상대팀',
              textAlign: TextAlign.right,
              style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTeamScore(widget.game.homeTeam.id, widget.game.homeScore, true),
          _buildScoreColon(),
          _buildTeamScore(
            widget.game.awayTeam.id,
            widget.game.awayScore,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String teamId, int score, bool isHome) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          isHome
              ? [
                _buildTeamWithLogo(teamId),
                const SizedBox(width: 8),
                _buildScoreText(score),
              ]
              : [
                _buildScoreText(score),
                const SizedBox(width: 8),
                _buildTeamWithLogo(teamId),
              ],
    );
  }

  Widget _buildScoreText(int score) {
    return Text(
      widget.game.canceled ? '-' : score.toString(),
      style: AppTextStyles.h2.copyWith(color: AppColors.navy),
    );
  }

  Widget _buildScoreColon() {
    return Container(
      width: 25,
      alignment: Alignment.center,
      child: Text(
        ':',
        style: AppTextStyles.h3.copyWith(color: AppColors.gray70),
      ),
    );
  }

  Widget _buildTeamWithLogo(String teamId) {
    final team = _getTeamById(teamId);

    // 팀 정보가 없을 경우 게임 레코드에서 정보 가져오기
    String teamName = '알 수 없는 팀';
    if (team != null) {
      teamName = team.name;
    } else {
      // 게임 레코드에서 팀 이름 찾기
      if (teamId == widget.game.homeTeam.id) {
        teamName = widget.game.homeTeam.name;
      } else if (teamId == widget.game.awayTeam.id) {
        teamName = widget.game.awayTeam.name;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _teamLogoSize,
          height: _teamLogoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: _buildTeamLogo(team)),
        ),
        const SizedBox(width: 6),
        Text(
          teamName,
          style: AppTextStyles.body3.copyWith(color: AppColors.navy),
        ),
      ],
    );
  }

  Widget _buildTeamLogo(app_models.Team? team) {
    if (team == null) {
      return _buildDefaultTeamIcon();
    }

    if (team.logo != null && team.logo!.isNotEmpty) {
      if (team.logo!.startsWith('assets/')) {
        return Image.asset(
          team.logo!,
          width: _teamLogoSize,
          height: _teamLogoSize,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) => _buildFallbackLogo(team),
        );
      } else {
        return Center(
          child: Text(
            team.logo!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return _buildFallbackLogo(team);
  }

  Widget _buildFallbackLogo(app_models.Team team) {
    if (team.shortName.isNotEmpty) {
      return Container(
        width: _teamLogoSize,
        height: _teamLogoSize,
        color: AppColors.gray10,
        child: Center(
          child: Text(
            team.shortName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
        ),
      );
    }

    return _buildDefaultTeamIcon();
  }

  Widget _buildDefaultTeamIcon() {
    return Container(
      width: _teamLogoSize,
      height: _teamLogoSize,
      color: AppColors.gray20,
      child: const Icon(
        Icons.sports_baseball,
        size: 20,
        color: AppColors.gray50,
      ),
    );
  }

  Widget _buildGameCancelCheckbox() {
    final bool isCanceled = widget.game.canceled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isCanceled ? const Color(0xFFD7DCE7) : AppColors.gray20,
              borderRadius: BorderRadius.circular(4),
            ),
            child:
                isCanceled
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 5),
          Text(
            '경기취소',
            style: AppTextStyles.body3.copyWith(
              color: const Color(0xFFB5BDCB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDivider(),
          const SizedBox(height: _infoRowVerticalPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _labelWidth,
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '코멘트',
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    widget.game.memo.isEmpty ? '코멘트가 없습니다.' : widget.game.memo,
                    style: AppTextStyles.body3.copyWith(
                      color:
                          widget.game.memo.isEmpty
                              ? AppColors.gray50
                              : AppColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _infoRowVerticalPadding),
          _buildDivider(),
          const SizedBox(height: _verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildMemorableGameSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '기억에 남는 경기였나요?',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
          ),
          const SizedBox(height: 15),
          Center(
            child: GestureDetector(
              onTap: _handleFavoriteToggle,
              child: AnimatedScale(
                scale: _currentGame?.isFavorite == true ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: _heartIconSize,
                  height: 56,
                  alignment: Alignment.center,
                  child: Icon(
                    _currentGame?.isFavorite == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        _currentGame?.isFavorite == true
                            ? AppColors.negative
                            : AppColors.gray50,
                    size: _heartIconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray20, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.gray50,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_baseball), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: '',
          ),
        ],
      ),
    );
  }

  void _handleDownload() {
    if (widget.game.photos.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장할 이미지가 없습니다.')));
      return;
    }

    ImageSaveService.saveImageToGallery(widget.game.photos.first, context);
  }

  void _showActionModal() {
    RecordActionModal.show(
      context,
      onEdit: _handleEdit,
      onDelete: _handleDelete,
    );
  }

  void _handleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRecordScreen(gameRecord: widget.game),
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  void _handleDelete() {
    _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '기록 삭제',
              style: AppTextStyles.h2.copyWith(color: AppColors.black),
            ),
            content: Text(
              '이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
              style: AppTextStyles.body2.copyWith(color: AppColors.gray80),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: AppTextStyles.body2.copyWith(color: AppColors.gray80),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    final success = await RecordService().deleteRecord(
                      widget.game.id,
                    );

                    if (success) {
                      if (mounted) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('기록이 삭제되었습니다'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('기록 삭제에 실패했습니다'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('삭제 중 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  '삭제',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.negative,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _handleFavoriteToggle() async {
    if (_currentGame == null) return;

    try {
      final recordService = RecordService();
      final success = await recordService.toggleFavorite(_currentGame!.id);

      if (success && mounted) {
        final newFavoriteStatus = !_currentGame!.isFavorite;

        setState(() {
          _currentGame = _currentGame!.copyWith(isFavorite: newFavoriteStatus);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newFavoriteStatus ? '좋아하는 경기에 추가했어요' : '좋아하는 경기에서 제거했어요',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('즐겨찾기 업데이트에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
