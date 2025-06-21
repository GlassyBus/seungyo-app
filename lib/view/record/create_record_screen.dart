import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:collection/collection.dart';
import 'package:seungyo/models/game_record_form.dart';
import 'package:seungyo/models/game_schedule.dart';
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/services/record_service.dart';
import 'package:seungyo/utils/stadium_mapping.dart';

import '../../models/game_record.dart';
import '../../models/stadium.dart' as app_models;
import '../../models/team.dart' as app_models;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'widgets/date_time_picker_modal.dart';
import 'widgets/image_editor_screen.dart';
import 'widgets/score_input_modal.dart';
import 'widgets/stadium_picker_modal.dart';
import 'widgets/team_picker_modal.dart';

class CreateRecordScreen extends StatefulWidget {
  final GameRecord? gameRecord; // 수정할 기록 (null이면 새 기록)
  final GameSchedule? gameSchedule; // 미리 설정할 경기 정보 (null이면 빈 폼)

  const CreateRecordScreen({super.key, this.gameRecord, this.gameSchedule});

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late RecordService _recordService;
  late GameRecordForm _form;
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  List<File> _selectedImages = [];
  bool _isMemorableGame = false;
  bool _isGameCanceled = false; // 경기취소 상태
  bool _isImageLoading = false;
  bool _isSaving = false;
  List<app_models.Stadium> _stadiums = [];
  List<app_models.Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _recordService = RecordService();
    _form = GameRecordForm();
    _loadStadiums();
    _loadTeams();

    // 수정 모드인 경우 기존 데이터로 초기화
    if (widget.gameRecord != null) {
      _initializeWithExistingRecord();
    }
    // 경기 일정 정보가 있는 경우 해당 정보로 초기화
    else if (widget.gameSchedule != null) {
      _initializeWithSchedule();
    }

    // 디버그: DB 상태 확인
    _debugDatabaseStatus();
  }

  void _initializeWithSchedule() {
    final schedule = widget.gameSchedule!;
    if (kDebugMode) if (kDebugMode) {
      print(
      'CreateRecordScreen: Initializing with schedule - ${schedule.homeTeam} vs ${schedule.awayTeam} at ${schedule.stadium}',
    );
    }

    // 경기장 ID 매핑
    String? stadiumId = StadiumMapping.getBestStadiumId(
      schedule.stadium,
      schedule.homeTeam,
    );

    // 팀 ID 매핑
    String? homeTeamId = _getTeamIdByName(schedule.homeTeam);
    String? awayTeamId = _getTeamIdByName(schedule.awayTeam);

    if (kDebugMode) if (kDebugMode) {
      print(
      'CreateRecordScreen: Mapped stadium "${schedule.stadium}" -> "$stadiumId"',
    );
    }
    if (kDebugMode) if (kDebugMode) {
      print(
      'CreateRecordScreen: Mapped home team "${schedule.homeTeam}" -> "$homeTeamId"',
    );
    }
    if (kDebugMode) if (kDebugMode) {
      print(
      'CreateRecordScreen: Mapped away team "${schedule.awayTeam}" -> "$awayTeamId"',
    );
    }

    // 기본적으로 경기 시간, 경기장, 팀 정보 설정
    setState(() {
      _form = _form.copyWith(
        gameDateTime: schedule.dateTime,
        stadiumId: stadiumId,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      );
    });
  }

  /// 팀 이름으로 팀 ID 찾기
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

    String? teamId = teamNameMapping[teamName];
    if (teamId != null) {
      return teamId;
    }

    // 직접 매핑에서 찾을 수 없으면 로드된 팀 목록에서 찾기
    final team = _teams.firstWhereOrNull(
      (t) =>
          t.name.contains(teamName) ||
          t.shortName == teamName ||
          teamName.contains(t.shortName),
    );

    return team?.id;
  }

  void _initializeWithExistingRecord() {
    final record = widget.gameRecord!;
    if (kDebugMode) if (kDebugMode) {
      print(
      'CreateRecordScreen: Initializing with existing record ID: ${record.id}',
    );
    }

    // 폼 데이터 설정
    _form = GameRecordForm(
      gameDateTime: record.dateTime,
      stadiumId: record.stadium.id,
      homeTeamId: record.homeTeam.id,
      awayTeamId: record.awayTeam.id,
      homeScore: record.homeScore,
      awayScore: record.awayScore,
      seatInfo: record.seatInfo,
      comment: record.memo,
      isFavorite: record.isFavorite,
      canceled: record.canceled,
    );

    // 컨트롤러에 텍스트 설정
    _seatController.text = record.seatInfo ?? '';
    _commentController.text = record.memo;

    // 체크박스 상태 설정
    _isMemorableGame = record.isFavorite;
    _isGameCanceled = record.canceled;

    // 기존 이미지들 로드
    if (record.photos.isNotEmpty) {
      _selectedImages = record.photos.map((path) => File(path)).toList();
      _form = _form.copyWith(imagePaths: record.photos);
    }

    if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form initialized with existing data');
    if (kDebugMode) if (kDebugMode) print('  - DateTime: ${_form.gameDateTime}');
    if (kDebugMode) if (kDebugMode) print('  - Stadium: ${_form.stadiumId}');
    if (kDebugMode) if (kDebugMode) print('  - Home Team: ${_form.homeTeamId}');
    if (kDebugMode) if (kDebugMode) print('  - Away Team: ${_form.awayTeamId}');
    if (kDebugMode) if (kDebugMode) print('  - Seat: ${_form.seatInfo}');
    if (kDebugMode) if (kDebugMode) print('  - Comment: ${_form.comment}');
    if (kDebugMode) if (kDebugMode) print('  - Photos: ${record.photos.length}');
  }

  Future<void> _debugDatabaseStatus() async {
    if (kDebugMode) if (kDebugMode) print('=== CreateRecordScreen - DB 상태 확인 ===');
    await DatabaseService().printDatabaseStatus();
  }

  Future<void> _loadStadiums() async {
    try {
      final stadiums = await DatabaseService().getStadiumsAsAppModels();
      setState(() {
        _stadiums = stadiums;
      });
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error loading stadiums: $e');
    }
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await DatabaseService().getTeamsAsAppModels();
      setState(() {
        _teams = teams;
      });
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error loading teams: $e');
    }
  }

  String _getStadiumNameById(String stadiumId) {
    final stadium = _stadiums.firstWhereOrNull((s) => s.id == stadiumId);
    if (stadium != null) {
      return stadium.name;
    }
    return stadiumId; // fallback to ID if stadium not found
  }

  String _getTeamNameById(String teamId) {
    final team = _teams.firstWhereOrNull((t) => t.id == teamId);
    if (team != null) {
      return team.name;
    }
    return teamId; // fallback to ID if team not found
  }

  @override
  void dispose() {
    _seatController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: _handleBackPress,
      ),
      title: Text(
        widget.gameRecord != null ? '직관 기록 수정' : '직관 기록 작성',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        _isSaving
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
            : IconButton(
              icon: Icon(
                Icons.check,
                color:
                    _canSave()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
              ),
              onPressed: _canSave() ? _handleSave : null,
            ),
      ],
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 25),
              _buildInfoSection(),
              const SizedBox(height: 25),
              _buildGameInfoSection(),
              const SizedBox(height: 25),
              _buildCommentSection(),
              const SizedBox(height: 25),
              _buildMemorableGameSection(),
              SizedBox(
                height:
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _isImageLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '이미지 로딩 중...',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.gray70,
                        ),
                      ),
                    ],
                  ),
                )
                : _selectedImages.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedImages.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _navigateToImageEditor(0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedImages.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${_selectedImages.length - 1}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gray50,
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: AppColors.gray50,
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '사진 추가',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.gray50,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoRow(
          '일정',
          _form.gameDateTime != null
              ? _formatDateTime(_form.gameDateTime!)
              : '날짜를 선택해주세요.',
          () => _showDateTimePicker(),
        ),
        Divider(color: AppColors.gray20, height: 1),
        const SizedBox(height: 18),
        _buildInfoRow(
          '위치',
          _form.stadiumId != null
              ? _getStadiumNameById(_form.stadiumId!)
              : '경기장을 선택해주세요.',
          () => _showStadiumPicker(),
        ),
        Divider(color: AppColors.gray20, height: 1),
        const SizedBox(height: 18),
        _buildInfoRow(
          '좌석',
          _seatController.text.isNotEmpty
              ? _seatController.text
              : '좌석을 입력해주세요.',
          null,
          isTextField: true,
        ),
        Divider(color: AppColors.gray20, height: 1),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    VoidCallback? onTap, {
    bool isTextField = false,
  }) {
    final isPlaceholder = value.contains('선택해주세요') || value.contains('입력해주세요');

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            label,
            style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              isTextField
                  ? TextField(
                    controller: _seatController,
                    decoration: InputDecoration(
                      hintText: '좌석을 입력해주세요.',
                      hintStyle: AppTextStyles.body3.copyWith(
                        color: AppColors.gray50,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 1),
                      isDense: true,
                    ),
                    style: AppTextStyles.body3.copyWith(color: AppColors.black),
                    onChanged: (value) {
                      setState(() {
                        _form = _form.copyWith(
                          seatInfo: value.isEmpty ? null : value,
                        );
                      });
                    },
                  )
                  : Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      value,
                      style: AppTextStyles.body3.copyWith(
                        color:
                            isPlaceholder ? AppColors.gray50 : AppColors.black,
                      ),
                    ),
                  ),
        ),
        if (onTap != null)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Transform.rotate(
              angle: 3.14159,
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: AppColors.gray50,
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: content,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: content,
    );
  }

  Widget _buildGameInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경기 정보',
          style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.navy5,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            children: [
              // 응원팀/상대팀 레이블
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '응원팀',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.gray80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '상대팀',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.gray80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 팀 정보와 스코어
              Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 좌측: 응원팀 (홈팀) - 팀 버튼 + 스코어
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Flexible(
                            child: _buildTeamButtonWithLogo(
                              _form.homeTeamId,
                              () => _showTeamPicker(true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildScoreButton(
                            _isGameCanceled
                                ? '-'
                                : (_form.homeScore != null
                                    ? '${_form.homeScore}'
                                    : '-'),
                            (_form.homeTeamId != null &&
                                    _form.awayTeamId != null &&
                                    !_isGameCanceled)
                                ? _showScoreInput
                                : null,
                          ),
                        ],
                      ),
                    ),
                    // 중앙: 구분자 (:)
                    Container(
                      width: 25,
                      alignment: Alignment.center,
                      child: Text(
                        ':',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.gray50,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // 우측: 상대팀 (어웨이팀) - 스코어 + 팀 버튼
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildScoreButton(
                            _isGameCanceled
                                ? '-'
                                : (_form.awayScore != null
                                    ? '${_form.awayScore}'
                                    : '-'),
                            (_form.homeTeamId != null &&
                                    _form.awayTeamId != null &&
                                    !_isGameCanceled)
                                ? _showScoreInput
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildTeamButtonWithLogo(
                              _form.awayTeamId,
                              () => _showTeamPicker(false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildGameCancelCheckbox(),
      ],
    );
  }

  Widget _buildTeamButtonWithLogo(String? teamId, VoidCallback onTap) {
    if (teamId != null) {
      final team = _teams.firstWhereOrNull((t) => t.id == teamId);

      return GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(child: _buildTeamLogo(team)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _getTeamNameById(teamId),
                style: AppTextStyles.body3.copyWith(color: AppColors.navy),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '팀 선택',
            style: AppTextStyles.body3.copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildTeamLogo(app_models.Team? team) {
    if (team == null) {
      return _buildDefaultTeamIcon();
    }

    if (team.logo != null && team.logo!.isNotEmpty) {
      if (team.logo!.startsWith('assets/')) {
        return Image.asset(
          team.logo!,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo(team);
          },
        );
      } else {
        return Center(
          child: Text(team.logo!, style: const TextStyle(fontSize: 20)),
        );
      }
    } else {
      return _buildFallbackLogo(team);
    }
  }

  Widget _buildFallbackLogo(app_models.Team team) {
    if (team.shortName.isNotEmpty) {
      return Center(
        child: Text(
          team.shortName.substring(0, 1),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.sports_baseball, size: 20, color: AppColors.navy),
      );
    }
  }

  Widget _buildDefaultTeamIcon() {
    return Container(
      width: 30,
      height: 30,
      color: AppColors.gray20,
      child: Icon(Icons.sports_baseball, size: 20, color: AppColors.gray50),
    );
  }

  Widget _buildGameCancelCheckbox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isGameCanceled = !_isGameCanceled;
                if (kDebugMode) if (kDebugMode) {
                  print(
                  'CreateRecordScreen: Game canceled toggled to: $_isGameCanceled',
                );
                }
                if (_isGameCanceled) {
                  if (kDebugMode) if (kDebugMode) {
                    print(
                    'CreateRecordScreen: Clearing scores due to cancellation',
                  );
                  }
                  _form = _form.copyWith(homeScore: null, awayScore: null);
                }
              });
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _isGameCanceled ? AppColors.navy : AppColors.gray30,
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  _isGameCanceled
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '경기취소',
            style: AppTextStyles.body3.copyWith(
              color: _isGameCanceled ? AppColors.navy : AppColors.gray50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.gray20, height: 1),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                '코멘트',
                style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _commentController,
                maxLines: null,
                textAlign: TextAlign.left,
                style: AppTextStyles.body3.copyWith(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: '코멘트를 남겨주세요.',
                  hintStyle: AppTextStyles.body3.copyWith(
                    color: AppColors.gray50,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 1),
                  isDense: true,
                ),
                onChanged: (value) {
                  _form = _form.copyWith(comment: value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Divider(color: AppColors.gray20, height: 1),
      ],
    );
  }

  Widget _buildMemorableGameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '기억에 남는 경기였나요?',
          style: AppTextStyles.body3.copyWith(color: AppColors.gray80),
        ),
        const SizedBox(height: 15),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isMemorableGame = !_isMemorableGame;
              });
            },
            child: AnimatedScale(
              scale: _isMemorableGame ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 60,
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  _isMemorableGame ? Icons.favorite : Icons.favorite_border,
                  color:
                      _isMemorableGame ? AppColors.negative : AppColors.gray50,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('카메라로 촬영'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('갤러리에서 선택'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('여러 사진 선택'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickMultipleImages();
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // 이미지 처리 시간을 시뮬레이션 (실제 앱에서는 필요 없음)
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _selectedImages = [File(pickedFile.path)];
          _form = _form.copyWith(imagePaths: [pickedFile.path]);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 로딩 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        // 이미지 처리 시간을 시뮬레이션
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
          _form = _form.copyWith(
            imagePaths: pickedFiles.map((file) => file.path).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 로딩 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _showDateTimePicker() async {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => DateTimePickerModal(
              initialDateTime: _form.gameDateTime,
              onDateTimeSelected: (dateTime) {
                setState(() {
                  _form = _form.copyWith(gameDateTime: dateTime);
                });
              },
              gameSchedules: null, // 모달에서 직접 로드하므로 null 전달
            ),
      );
    }
  }

  void _showStadiumPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => StadiumPickerModal(
            selectedStadium: _form.stadiumId,
            onStadiumSelected: (stadiumId) {
              setState(() {
                _form = _form.copyWith(stadiumId: stadiumId);
              });
            },
            stadiums: _stadiums,
          ),
    );
  }

  void _showTeamPicker(bool isHomeTeam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => TeamPickerModal(
            title: isHomeTeam ? '응원팀 선택' : '상대팀 선택',
            selectedTeam: isHomeTeam ? _form.homeTeamId : _form.awayTeamId,
            onTeamSelected: (teamId) {
              setState(() {
                if (isHomeTeam) {
                  _form = _form.copyWith(homeTeamId: teamId);
                } else {
                  _form = _form.copyWith(awayTeamId: teamId);
                }
              });
            },
            teams: _teams,
          ),
    );
  }

  void _showScoreInput() {
    if (_form.homeTeamId == null || _form.awayTeamId == null || _isGameCanceled) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ScoreInputModal(
            homeTeam: _form.homeTeamId!,
            awayTeam: _form.awayTeamId!,
            initialHomeScore: _form.homeScore,
            initialAwayScore: _form.awayScore,
            onScoreSelected: (homeScore, awayScore) {
              setState(() {
                _form = _form.copyWith(
                  homeScore: homeScore,
                  awayScore: awayScore,
                );
              });
            },
          ),
    );
  }

  bool _canSave() {
    return _form.gameDateTime != null &&
        _form.stadiumId != null &&
        _form.homeTeamId != null &&
        _form.awayTeamId != null;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Cannot save - validation failed');
      return;
    }

    try {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Starting save process...');
      setState(() {
        _isSaving = true;
      });

      // 폼 데이터 업데이트
      _form = _form.copyWith(
        seatInfo: _seatController.text.isEmpty ? null : _seatController.text,
        comment:
            _commentController.text.isEmpty ? null : _commentController.text,
        isFavorite: _isMemorableGame, // 기억에 남는 경기는 자동으로 즐겨찾기에 추가
        canceled: _isGameCanceled, // 경기취소 상태
        // 경기취소시에는 점수를 null로 유지 (이미 체크박스에서 null로 설정됨)
      );

      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form updated with final data');
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Final form validation: ${_form.isValid}');
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form data summary:');
      if (kDebugMode) if (kDebugMode) print('  - DateTime: ${_form.gameDateTime}');
      if (kDebugMode) if (kDebugMode) print('  - Stadium: ${_form.stadiumId}');
      if (kDebugMode) if (kDebugMode) print('  - Home Team: ${_form.homeTeamId}');
      if (kDebugMode) if (kDebugMode) print('  - Away Team: ${_form.awayTeamId}');
      if (kDebugMode) if (kDebugMode) print('  - Home Score: ${_form.homeScore}');
      if (kDebugMode) if (kDebugMode) print('  - Away Score: ${_form.awayScore}');
      if (kDebugMode) if (kDebugMode) print('  - Seat: ${_form.seatInfo}');
      if (kDebugMode) if (kDebugMode) print('  - Comment: ${_form.comment}');
      if (kDebugMode) if (kDebugMode) print('  - Is Favorite: ${_form.isFavorite}');
      if (kDebugMode) if (kDebugMode) print('  - Is Canceled: ${_form.canceled}'); // 이 부분이 중요!
      if (kDebugMode) if (kDebugMode) print('  - UI _isGameCanceled: $_isGameCanceled');

      await _submitForm();
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Save completed successfully');
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Save failed with error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
    } finally {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Resetting saving state');
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: _submitForm called');

    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form validation failed');
      return;
    }

    _formKey.currentState!.save();
    if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form state saved');

    if (!_form.isValid) {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Form isValid check failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('경기 날짜, 구장, 홈팀, 원정팀 정보를 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      if (widget.gameRecord != null) {
        // 수정 모드
        if (kDebugMode) if (kDebugMode) {
          print(
          'CreateRecordScreen: Updating existing record ID: ${widget.gameRecord!.id}',
        );
        }
        final success = await _recordService.updateRecord(
          widget.gameRecord!.id,
          _form,
        );

        if (success) {
          if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Record updated successfully');
        } else {
          throw Exception('Failed to update record');
        }
      } else {
        // 새 기록 추가 모드
        if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Adding new record...');
        final recordId = await _recordService.addRecord(_form);
        if (kDebugMode) if (kDebugMode) {
          print(
          'CreateRecordScreen: Record added successfully with ID: $recordId',
        );
        }
      }

      if (mounted) {
        if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Navigating back with success result');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('CreateRecordScreen: Error in _submitForm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.gameRecord != null
                  ? '기록 수정 중 오류가 발생했습니다: $e'
                  : '기록 저장 중 오류가 발생했습니다: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleBackPress() {
    if (_isSaving) return;
    _showExitConfirmDialog();
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 5),
                // 제목
                Text(
                  '작성을 그만두시겠어요?',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // 설명
                Text(
                  '지금까지 작성된 내용은 저장되지 않아요.',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.gray80,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            actions: [
              Row(
                children: [
                  // 작성 계속하기 버튼
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '작성 계속하기',
                          style: AppTextStyles.body3.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 삭제하고 나가기 버튼
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 다이얼로그 닫기
                          Navigator.pop(context); // 작성 화면 닫기
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '삭제하고 나가기',
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.negative,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildScoreButton(String text, VoidCallback? onTap) {
    final isScoreText = text != ':';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: isScoreText ? 40 : 25,
          minHeight: 35,
        ),
        child: Center(
          child: Text(
            text,
            style:
                isScoreText
                    ? AppTextStyles.h2.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    )
                    : AppTextStyles.h3.copyWith(color: AppColors.gray70),
          ),
        ),
      ),
    );
  }

  void _navigateToImageEditor(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImageEditorScreen(
              image: _selectedImages[index],
              onImageEdited: (String editedImagePath) {
                setState(() {
                  _selectedImages[index] = File(editedImagePath);
                  _form = _form.copyWith(
                    imagePaths: _selectedImages.map((e) => e.path).toList(),
                  );
                });
              },
            ),
      ),
    );
  }
}
