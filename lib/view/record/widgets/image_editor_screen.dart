import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:crop_your_image/crop_your_image.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ImageEditorScreen extends StatefulWidget {
  final File image;
  final Function(String) onImageEdited;

  const ImageEditorScreen({
    super.key,
    required this.image,
    required this.onImageEdited,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final List<TextOverlay> _textOverlays = [];

  bool _isProcessing = false;

  late File _currentImage;
  final CropController _cropController = CropController();
  bool _showCropDialog = false;
  Uint8List? _cropTargetBytes;

  // 자르기 비율 선택
  double? _selectedAspectRatio;

  // 크롭 위젯을 위한 키 (비율 변경 시 위젯 재생성)
  Key _cropWidgetKey = const ValueKey('crop_free');

  @override
  void initState() {
    super.initState();
    _currentImage = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: Column(
            children: [Expanded(child: _buildImageView()), _buildToolbar()],
          ),
        ),
        if (_showCropDialog && _cropTargetBytes != null) _buildCropDialog(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '사진 편집',
        style: AppTextStyles.h3.copyWith(color: AppColors.black),
      ),
      centerTitle: true,
      actions: [
        if (_isProcessing)
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.navy,
              ),
            ),
          )
        else
          TextButton(
            onPressed: _saveAndExit,
            child: Text(
              '완료',
              style: AppTextStyles.button2.copyWith(color: AppColors.navy),
            ),
          ),
      ],
    );
  }

  Widget _buildImageView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.gray5,
      child: Stack(
        children: [
          // 이미지 표시
          FutureBuilder<bool>(
            future: _currentImage.exists(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return PhotoView(
                  imageProvider: FileImage(_currentImage),
                  backgroundDecoration: BoxDecoration(color: AppColors.gray5),
                  minScale: PhotoViewComputedScale.contained * 0.5,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  initialScale: PhotoViewComputedScale.contained,
                  loadingBuilder: (context, event) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.navy),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: AppColors.gray80, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            '이미지를 불러올 수 없습니다',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.gray80,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.navy),
                );
              }
            },
          ),
          // 텍스트 오버레이들
          ..._textOverlays.asMap().entries.map((entry) {
            final index = entry.key;
            final overlay = entry.value;
            return Positioned(
              left: overlay.position.dx,
              top: overlay.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) => _moveTextOverlay(index, details),
                onDoubleTap: () => _showTextDialog(editIndex: index),
                child: Text(
                  overlay.text,
                  style: TextStyle(
                    color: overlay.textColor,
                    fontSize: overlay.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray20, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolbarButton(Icons.crop_outlined, '자르기', _cropImage),
              _buildToolbarButton(Icons.text_fields_outlined, '텍스트', _addText),
              _buildToolbarButton(
                Icons.rotate_right_outlined,
                '회전',
                _rotateImage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navy5,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray20, width: 1),
              ),
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray80,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 자르기 기능
  Future<void> _cropImage() async {
    try {
      final bytes = await _currentImage.readAsBytes();
      setState(() {
        _cropTargetBytes = bytes;
        _showCropDialog = true;
      });
    } catch (e) {
      _showErrorMessage('이미지를 불러올 수 없습니다: $e');
    }
  }

  Widget _buildCropDialog() {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 상단 네비게이션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.gray20, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCropDialog = false;
                        _cropTargetBytes = null;
                        _selectedAspectRatio = null;
                      });
                    },
                    child: Text(
                      '취소',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.gray80,
                      ),
                    ),
                  ),
                  Text(
                    '자르기',
                    style: AppTextStyles.h3.copyWith(color: AppColors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      _cropController.crop();
                    },
                    child: Text(
                      '완료',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 자르기 영역
            Expanded(
              child: Container(
                color: AppColors.gray5,
                child: Crop(
                  key: _cropWidgetKey,
                  image: _cropTargetBytes!,
                  controller: _cropController,
                  onCropped: _handleCropCompleted,
                  aspectRatio: _selectedAspectRatio,
                  maskColor: AppColors.black.withValues(alpha: 0.5),
                  withCircleUi: false,
                  cornerDotBuilder:
                      (size, edgeAlignment) => Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                ),
              ),
            ),

            // 비율 선택 버튼들
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.gray20, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAspectRatioButton('자유', null),
                  _buildAspectRatioButton('1:1', 1.0),
                  _buildAspectRatioButton('4:3', 4.0 / 3.0),
                  _buildAspectRatioButton('16:9', 16.0 / 9.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatioButton(String label, double? ratio) {
    final isSelected = _selectedAspectRatio == ratio;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAspectRatio = ratio;
          // 비율에 따라 고유한 키 생성하여 위젯 강제 재생성
          if (ratio == null) {
            _cropWidgetKey = const ValueKey('crop_free');
          } else if (ratio == 1.0) {
            _cropWidgetKey = const ValueKey('crop_1_1');
          } else if (ratio == 4.0 / 3.0) {
            _cropWidgetKey = const ValueKey('crop_4_3');
          } else if (ratio == 16.0 / 9.0) {
            _cropWidgetKey = const ValueKey('crop_16_9');
          } else {
            _cropWidgetKey = ValueKey('crop_${ratio.toString()}');
          }
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : AppColors.gray5,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.gray20,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.gray80,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 텍스트 추가
  void _addText() {
    _showTextDialog();
  }

  void _showTextDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    final existingOverlay = isEditing ? _textOverlays[editIndex] : null;

    String text = existingOverlay?.text ?? '';
    Color textColor = existingOverlay?.textColor ?? Colors.white;
    double fontSize = existingOverlay?.fontSize ?? 24.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Text(
                          isEditing ? '텍스트 수정' : '텍스트 추가',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 텍스트 입력
                        Text(
                          '내용',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray5,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray20),
                          ),
                          child: TextField(
                            controller: TextEditingController(text: text),
                            onChanged: (value) {
                              setDialogState(() {
                                text = value;
                              });
                            },
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: '텍스트를 입력하세요',
                              hintStyle: TextStyle(color: AppColors.gray60),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 실시간 미리보기
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.gray10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray20),
                          ),
                          child: Center(
                            child: Text(
                              text.isEmpty ? '미리보기' : text,
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize * 0.6, // 미리보기용 작은 크기
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 텍스트 색상
                        Text(
                          '텍스트 색상',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.gray5,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray20),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                [
                                  Colors.white, // 화이트
                                  AppColors.black, // 블랙
                                  AppColors.navy, // 네이비 (브랜드)
                                  AppColors.mint, // 민트 (브랜드)
                                  AppColors.gray70, // 딥 그레이
                                  AppColors.positive, // 포지티브 그린
                                  AppColors.warning, // 워닝 옐로우
                                  AppColors.negative, // 네거티브 레드
                                ].map((color) {
                                  final isSelected = _areColorsEqual(
                                    textColor,
                                    color,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        textColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.navy
                                                  : AppColors.gray20,
                                          width: isSelected ? 3 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child:
                                          isSelected
                                              ? Icon(
                                                Icons.check,
                                                color:
                                                    color == Colors.white ||
                                                            color ==
                                                                AppColors
                                                                    .mint ||
                                                            color ==
                                                                AppColors
                                                                    .warning
                                                        ? AppColors.black
                                                        : Colors.white,
                                                size: 20,
                                              )
                                              : null,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 글자 크기
                        Text(
                          '글자 크기',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray5,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '작게',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.gray60,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: fontSize,
                                  min: 12,
                                  max: 48,
                                  divisions: 36,
                                  activeColor: AppColors.navy,
                                  inactiveColor: AppColors.gray30,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      fontSize = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                '크게',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.gray60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${fontSize.round()}px',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.gray10,
                                  foregroundColor: AppColors.gray70,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  '취소',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // 빈 텍스트도 허용 (공백 문자열도 텍스트로 취급)
                                  final overlay = TextOverlay(
                                    text:
                                        text.isEmpty ? '텍스트' : text, // 빈 경우 기본값
                                    position: Offset(
                                      MediaQuery.of(context).size.width / 2 -
                                          50,
                                      200,
                                    ),
                                    textColor: textColor,
                                    backgroundColor: Colors.transparent,
                                    fontSize: fontSize,
                                  );

                                  setState(() {
                                    if (isEditing) {
                                      _textOverlays[editIndex] = overlay;
                                    } else {
                                      _textOverlays.add(overlay);
                                    }
                                  });

                                  Navigator.pop(context);
                                  HapticFeedback.lightImpact();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isEditing ? '수정' : '추가',
                                  style: AppTextStyles.body2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _moveTextOverlay(int index, DragUpdateDetails details) {
    setState(() {
      final overlay = _textOverlays[index];
      _textOverlays[index] = TextOverlay(
        text: overlay.text,
        position: overlay.position + details.delta,
        textColor: overlay.textColor,
        backgroundColor: overlay.backgroundColor,
        fontSize: overlay.fontSize,
      );
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveAndExit() async {
    try {
      setState(() => _isProcessing = true);

      // 텍스트 오버레이가 있는 경우 이미지에 합성
      File finalImage = _currentImage;

      if (_textOverlays.isNotEmpty) {
        finalImage = await _combineTextWithImage(finalImage);
      }

      // 파일이 존재하는지 확인
      if (!await finalImage.exists()) {
        _showErrorMessage('저장할 이미지를 찾을 수 없습니다.');
        return;
      }

      // 파일 크기 확인 (너무 작으면 오류)
      final fileSize = await finalImage.length();
      if (fileSize < 100) {
        // 100바이트 미만이면 유효하지 않은 파일
        _showErrorMessage('이미지 파일이 손상되었습니다.');
        return;
      }

      widget.onImageEdited(finalImage.path);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) print('저장 오류: $e');
      _showErrorMessage('이미지 저장 중 오류가 발생했습니다.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<File> _combineTextWithImage(File imageFile) async {
    try {
      setState(() => _isProcessing = true);

      // MediaQuery를 async 함수 외부로 이동
      final screenSize = MediaQuery.of(context).size;

      // 원본 이미지 읽기
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('이미지를 읽을 수 없습니다');
      }

      final imageWidth = originalImage.width.toDouble();
      final imageHeight = originalImage.height.toDouble();

      if (kDebugMode) print('텍스트 오버레이 개수: ${_textOverlays.length}');

      // Canvas 설정
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 원본 이미지 그리기
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      canvas.drawImage(frame.image, Offset.zero, Paint());

      // 단순한 스케일링 (화면 너비 기준)
      final scaleX = imageWidth / screenSize.width;

      if (kDebugMode) print('이미지 원본 크기: ${imageWidth}x$imageHeight');
      if (kDebugMode) print('화면 크기: ${screenSize.width}x${screenSize.height}');
      if (kDebugMode) print('스케일: $scaleX');

      // 각 텍스트 오버레이 그리기
      for (final overlay in _textOverlays) {
        // 위치 스케일링
        final scaledX = overlay.position.dx * scaleX;
        final scaledY = overlay.position.dy * scaleX; // 동일한 스케일 사용
        final scaledFontSize = overlay.fontSize * scaleX;

        if (kDebugMode) {
          print('텍스트: ${overlay.text}');
          print('화면 좌표: (${overlay.position.dx}, ${overlay.position.dy})');
          print('이미지 좌표: ($scaledX, $scaledY)');
          print('폰트 크기: ${overlay.fontSize} -> $scaledFontSize');
        }

        // 메인 텍스트만 그리기 (그림자 효과 없음)
        final textPainter = TextPainter(
          text: TextSpan(
            text: overlay.text,
            style: TextStyle(
              color: overlay.textColor,
              fontSize: scaledFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(scaledX, scaledY));
      }

      // Picture를 Image로 변환
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        imageWidth.toInt(),
        imageHeight.toInt(),
      );

      // Image를 Uint8List로 변환
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('이미지를 바이트 데이터로 변환할 수 없습니다');
      }

      final finalBytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/final_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(finalBytes);

      if (kDebugMode) print('이미지 합성 완료: ${tempFile.path}');

      return tempFile;
    } catch (e) {
      if (kDebugMode) print('텍스트 합성 오류: $e');
      throw Exception('텍스트를 이미지에 합성하는 중 오류가 발생했습니다: $e');
    }
  }

  // 자르기 완료 처리
  Future<void> _handleCropCompleted(Uint8List croppedData) async {
    try {
      setState(() => _isProcessing = true);

      // 임시 파일 생성
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 고품질로 저장
      await tempFile.writeAsBytes(croppedData);

      // 파일 유효성 검증
      if (await tempFile.exists() && await tempFile.length() > 100) {
        setState(() {
          _currentImage = tempFile;
          _showCropDialog = false;
          _cropTargetBytes = null;
          _selectedAspectRatio = null; // 비율 선택 초기화
        });

        // 성공 햅틱 피드백
        HapticFeedback.heavyImpact();

        // 성공 메시지 (선택적)
        _showSuccessMessage('이미지가 성공적으로 잘렸습니다');
      } else {
        throw Exception('자른 이미지 파일이 유효하지 않습니다');
      }
    } catch (e) {
      if (kDebugMode) print('자르기 완료 처리 오류: $e');
      _showErrorMessage('이미지 자르기 중 오류가 발생했습니다');

      // 실패 시 다이얼로그 닫기
      setState(() {
        _showCropDialog = false;
        _cropTargetBytes = null;
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 색상 비교 함수
  bool _areColorsEqual(Color color1, Color color2) {
    return color1.toARGB32() == color2.toARGB32();
  }

  // 이미지 회전 - 개선된 버전
  Future<void> _rotateImage() async {
    setState(() => _isProcessing = true);

    try {
      // 현재 이미지 바이트 사용 (조정된 상태 유지)
      final bytes = await _currentImage.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        final rotatedImage = img.copyRotate(image, angle: 90);

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // 고품질로 저장
        await tempFile.writeAsBytes(img.encodeJpg(rotatedImage, quality: 95));

        if (mounted && await tempFile.exists()) {
          setState(() {
            _currentImage = tempFile;
          });
        } else {
          _showErrorMessage('회전된 이미지를 저장할 수 없습니다.');
        }
      } else {
        _showErrorMessage('이미지를 처리할 수 없습니다.');
      }
    } catch (e) {
      if (kDebugMode) print('이미지 회전 오류: $e');
      _showErrorMessage('이미지 회전 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// 텍스트 오버레이 클래스
class TextOverlay {
  final String text;
  final Offset position;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;

  TextOverlay({
    required this.text,
    required this.position,
    required this.textColor,
    required this.backgroundColor,
    required this.fontSize,
  });
}
