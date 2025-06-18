import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _hasChanges = false;
  final GlobalKey _bodyKey = GlobalKey();

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        // 변경사항이 있으면 true를 반환하여 이전 화면에 알림
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(),
        body: _buildBody(colorScheme, textTheme),
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
          icon: const Icon(Icons.download),
          onPressed: _handleDownload,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: _showActionModal,
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
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
            _buildGameInfoSection(textTheme),
            _buildCommentSection(colorScheme, textTheme),
            _buildMemorableGameSection(textTheme),
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

  Widget _buildGameInfoSection(TextTheme textTheme) {
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
          _buildGameInfoCard(textTheme),
          const SizedBox(height: 10),
          _buildGameCancelCheckbox(),
          const SizedBox(height: _verticalSpacing),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTeamLabels(textTheme),
          _buildScoreDisplay(textTheme),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildTeamLabels(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '홈팀',
          style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
        ),
        Text(
          '상대팀',
          style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTeamInfo(
          widget.game.homeTeam.name,
          widget.game.homeTeam.primaryColor,
          widget.game.homeTeam.logo ?? '',
          textTheme,
        ),
        Text('${widget.game.homeScore}', style: textTheme.displayLarge),
        Text(
          ':',
          style: textTheme.displayLarge?.copyWith(color: AppColors.gray50),
        ),
        Text('${widget.game.awayScore}', style: textTheme.displayLarge),
        _buildTeamInfo(
          widget.game.awayTeam.name,
          widget.game.awayTeam.primaryColor,
          widget.game.awayTeam.logo ?? '',
          textTheme,
        ),
      ],
    );
  }

  Widget _buildTeamInfo(
    String teamName,
    Color color,
    String logoPath,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray30, width: 1),
          ),
          child: Center(
            child:
                logoPath.isNotEmpty && logoPath.startsWith('assets/')
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        logoPath,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Text(
                              _getTeamShortText(teamName),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                      ),
                    )
                    : Text(
                      _getTeamShortText(teamName),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 8),
        Text(teamName, style: textTheme.titleMedium),
      ],
    );
  }

  /// 팀명을 간단한 텍스트 로고로 변환
  String _getTeamShortText(String teamName) {
    if (teamName.contains('KIA') || teamName.contains('타이거즈')) return 'KIA';
    if (teamName.contains('KT') || teamName.contains('위즈')) return 'KT';
    if (teamName.contains('LG') || teamName.contains('트윈스')) return 'LG';
    if (teamName.contains('NC') || teamName.contains('다이노스')) return 'NC';
    if (teamName.contains('SSG') || teamName.contains('랜더스')) return 'SSG';
    if (teamName.contains('두산') || teamName.contains('베어스')) return '두산';
    if (teamName.contains('롯데') || teamName.contains('자이언츠')) return '롯데';
    if (teamName.contains('삼성') || teamName.contains('라이온즈')) return '삼성';
    if (teamName.contains('키움') || teamName.contains('히어로즈')) return '키움';
    if (teamName.contains('한화') || teamName.contains('이글스')) return '한화';
    return '⚾';
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

  Widget _buildCommentSection(ColorScheme colorScheme, TextTheme textTheme) {
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

  Widget _buildMemorableGameSection(TextTheme textTheme) {
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
              onTap: _toggleFavorite,
              child: AnimatedScale(
                scale: _currentGame?.isFavorite == true ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.favorite,
                  color:
                      _currentGame?.isFavorite == true
                          ? AppColors.negative
                          : AppColors.gray30,
                  size: 80,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 캡처용 워터마크 추가
          Center(
            child: Text(
              '승리요정으로 기록한 소중한 추억 ⚾',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray50,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        // 수정 성공 시 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 수정되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true); // 수정이 완료되면 true 반환
      }
    });
  }

  void _handleDelete() {
    _showDeleteConfirmDialog();
  }

  Future<void> _toggleFavorite() async {
    try {
      // UI 즉시 업데이트
      setState(() {
        _currentGame = _currentGame!.copyWith(
          isFavorite: !_currentGame!.isFavorite,
        );
      });

      // RecordService를 사용하여 DB 업데이트
      final recordService = RecordService();
      final success = await recordService.toggleFavorite(_currentGame!.id);

      if (!success) {
        // DB 업데이트 실패 시 UI 롤백
        setState(() {
          _currentGame = _currentGame!.copyWith(
            isFavorite: !_currentGame!.isFavorite,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('즐겨찾기 업데이트에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // 성공 시 - 뒤로 갈 때 리스트 새로고침을 위해 플래그 설정
        _hasChanges = true;

        // 성공 피드백
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _currentGame!.isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // 에러 발생 시 UI 롤백
      setState(() {
        _currentGame = _currentGame!.copyWith(
          isFavorite: !_currentGame!.isFavorite,
        );
      });

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
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  _performDelete(); // 실제 삭제 수행
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

  Future<void> _performDelete() async {
    try {
      print(
        'RecordDetailScreen: Starting delete process for record ID: ${widget.game.id}',
      );

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('기록을 삭제하는 중...'),
              ],
            ),
            duration: Duration(seconds: 30), // 충분한 시간
          ),
        );
      }

      // RecordService를 사용하여 DB에서 삭제
      final recordService = RecordService();
      final success = await recordService.deleteRecord(widget.game.id);

      // 로딩 스낵바 제거
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (success) {
        print('RecordDetailScreen: Record deleted successfully');

        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 삭제되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // 상세 화면 닫고 리스트 새로고침을 위해 true 반환
          Navigator.pop(context, true);
        }
      } else {
        print('RecordDetailScreen: Failed to delete record');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록 삭제에 실패했습니다.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('RecordDetailScreen: Error during delete: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    try {
      // 권한 요청
      await _requestPermissions();

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('이미지를 저장하는 중...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      // 캡처용 위젯을 별도로 생성하여 이미지화
      final captureWidget = _buildCaptureWidget(colorScheme, textTheme);

      // 위젯을 화면 밖에서 렌더링하기 위해 Offstage로 감싸서 build
      await _buildOffstageWidget(captureWidget);

      // 잠시 대기하여 위젯이 완전히 렌더링되도록 함
      await Future.delayed(const Duration(milliseconds: 500));

      // RepaintBoundary에서 이미지 추출
      final boundary =
          _bodyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('캡처할 영역을 찾을 수 없습니다.');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('이미지 데이터를 생성할 수 없습니다.');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 임시 파일 생성
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'seungyo_record_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(path.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(pngBytes);

      // gal 패키지를 사용하여 갤러리에 저장
      await Gal.putImage(tempFile.path, album: 'Seungyo');

      // 임시 파일 삭제
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // 로딩 스낵바 제거
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지가 갤러리에 저장되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 로딩 스낵바 제거
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 위젯을 화면 밖에서 렌더링하는 헬퍼 메서드
  Future<void> _buildOffstageWidget(Widget widget) async {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: -1000, // 화면 밖에 위치
            top: -1000,
            child: Material(child: widget),
          ),
    );

    overlay.insert(overlayEntry);

    // 다음 프레임까지 대기
    await WidgetsBinding.instance.endOfFrame;

    // 잠시 후 제거
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry?.remove();
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13 (API 33) 이상에서는 특별한 권한이 필요하지 않음
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return; // Android 13 이상에서는 권한 요청 불필요
      }

      // Android 12 이하에서는 WRITE_EXTERNAL_STORAGE 권한 필요
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('저장소 권한이 필요합니다.');
      }
    } else if (Platform.isIOS) {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('사진 접근 권한이 필요합니다.');
      }
    }
  }

  Future<int> _getAndroidVersion() async {
    try {
      return 30; // 기본값으로 처리
    } catch (e) {
      return 30; // 기본값 (Android 11)
    }
  }

  // 캡처용 별도 위젯 - 스크롤 없이 전체 높이로 렌더링
  Widget _buildCaptureWidget(ColorScheme colorScheme, TextTheme textTheme) {
    return RepaintBoundary(
      key: _bodyKey,
      child: Container(
        color: colorScheme.surface,
        width: 400, // 고정 너비로 깔끔한 이미지 생성
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 캡처용 헤더 추가
            _buildCaptureHeader(textTheme),
            const SizedBox(height: 16),
            _buildMainImage(),
            _buildGameInfo(textTheme),
            const SizedBox(height: 32),
            _buildGameResultSection(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildCommentSection(colorScheme, textTheme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 캡처용 헤더 위젯
  Widget _buildCaptureHeader(TextTheme textTheme) {
    // myTeam이 없으면 홈팀을 기본으로 사용
    final myTeam = widget.game.myTeam ?? widget.game.homeTeam;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 내 팀 로고
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child:
                  myTeam.logo?.isNotEmpty == true &&
                          myTeam.logo!.startsWith('assets/')
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          myTeam.logo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Text(
                                _getTeamShortText(myTeam.name),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                        ),
                      )
                      : Text(
                        _getTeamShortText(myTeam.name),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),
          // 내 팀명
          Text(
            myTeam.name,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
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

  Widget _buildGameInfo(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${_formatDateTime(widget.game.dateTime)} · ${widget.game.stadium.name}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (widget.game.seatInfo != null)
            Text('좌석: ${widget.game.seatInfo}', style: textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildGameResultSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTeamLabels(textTheme),
          const SizedBox(height: 8),
          _buildScoreDisplay(textTheme),
          if (widget.game.canceled) ...[
            const SizedBox(height: 8),
            Text(
              '경기취소',
              style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
            ),
          ],
        ],
      ),
    );
  }
}
