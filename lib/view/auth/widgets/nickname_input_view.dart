import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class NicknameInputView extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NicknameInputView({super.key, required this.onNext, required this.onBack});

  @override
  State<NicknameInputView> createState() => _NicknameInputViewState();
}

class _NicknameInputViewState extends State<NicknameInputView> {
  final TextEditingController _controller = TextEditingController();
  bool isTextFieldFocused = false;
  FocusNode focusNode = FocusNode();

  // 닉네임 최소/최대 길이 제한
  static const int _minLength = 2;
  static const int _maxLength = 10;

  // 닉네임 유효성 상태
  String? _validationMessage;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    focusNode.addListener(() {
      setState(() {
        isTextFieldFocused = focusNode.hasFocus;
      });
    });
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final length = text.length;

    setState(() {
      // 닉네임 유효성 검사
      if (length < _minLength) {
        _validationMessage = null; // 2글자 미만이면 메시지 표시 안함
        _isValid = false;
      } else if (length > _maxLength) {
        _validationMessage = "닉네임은 최대 ${_maxLength}글자까지 가능해요.";
        _isValid = false;
      } else {
        _validationMessage = "사용 가능한 닉네임이에요.";
        _isValid = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final team = vm.team ?? '';
    final teamName = vm.teamName ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          FocusScope.of(context).unfocus();
          widget.onBack();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('정보 입력', style: AppTextStyles.subtitle1),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.onBack();
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 컨텐츠 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 팀 로고 이미지 (원형 프레임 안에)
                      if (team.isNotEmpty)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.navy5,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gray30, width: 1),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Image.asset(TeamData.getByCode(team)?.emblem ?? '', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),

                      // 타이틀 텍스트
                      Text(
                        teamName.isNotEmpty ? '$teamName 승요의\n닉네임을 입력해주세요.' : '닉네임을 입력해주세요.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3.copyWith(color: AppColors.navy),
                      ),
                      const SizedBox(height: 30),

                      // 닉네임 입력 필드
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.navy5,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isTextFieldFocused ? AppColors.navy : AppColors.gray30, width: 1),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body2,
                            maxLength: _maxLength,
                            // 최대 글자 수 제한
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            // 카운터 숨기기
                            decoration: InputDecoration(
                              hintText: 'ex. 두산승리요정',
                              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.gray50),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                      ),

                      // 닉네임 유효성 메시지 (텍스트 길이가 최소 길이 이상일 때만 표시)
                      if (_controller.text.trim().length >= _minLength)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 체크 아이콘 또는 경고 아이콘
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _isValid ? AppColors.positiveBG : AppColors.negativeBG,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    _isValid ? Icons.check : Icons.close,
                                    size: 12,
                                    color: _isValid ? AppColors.positive : AppColors.negative,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // 메시지 텍스트
                              Text(
                                _validationMessage ?? '',
                                style: AppTextStyles.caption.copyWith(
                                  color: _isValid ? AppColors.positive : AppColors.negative,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // 등록 완료 버튼
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed:
                            _controller.text.trim().length >= _minLength && _controller.text.trim().length <= _maxLength
                                ? () async {
                                  FocusScope.of(context).unfocus();
                                  vm.setNickname(_controller.text.trim());
                                  await vm.saveUserInfo();
                                  widget.onNext();
                                }
                                : null,
                        style: TextButton.styleFrom(
                          backgroundColor:
                              _isValid
                                  ? AppColors
                                      .navy // 유효하면 네이비 색상
                                  : AppColors.navy5,
                          // 유효하지 않으면 연한 회색
                          foregroundColor:
                              _isValid
                                  ? Colors
                                      .white // 유효하면 흰색 텍스트
                                  : AppColors.navy30,
                          // 유효하지 않으면 연한 네이비 텍스트
                          disabledForegroundColor: AppColors.navy30,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('등록 완료', style: AppTextStyles.subtitle2),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // iOS 홈 인디케이터
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
