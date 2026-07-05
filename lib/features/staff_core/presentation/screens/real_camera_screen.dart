import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class RealCameraScreen extends StatefulWidget {
  const RealCameraScreen({Key? key}) : super(key: key);

  @override
  State<RealCameraScreen> createState() => _RealCameraScreenState();
}

class _RealCameraScreenState extends State<RealCameraScreen> {
  late html.VideoElement _videoElement;
  bool _isInitialized = false;
  String? _errorMessage;
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'web-camera-view-${DateTime.now().millisecondsSinceEpoch}';
    _initPureWebCamera();
  }

  Future<void> _initPureWebCamera() async {
    try {
      // 1. Khởi tạo thẻ <video> HTML5 thuần
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // 2. Đăng ký thẻ video này vào Flutter Web engine với tên định danh ĐỘC NHẤT
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement,
      );

      // 3. Gọi trực tiếp API getUserMedia của trình duyệt (Y hệt cách webcamtests.com hoạt động)
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true, // Không ép buộc độ phân giải, để trình duyệt tự do chọn luồng phù hợp nhất
        'audio': false,
      });

      _videoElement.srcObject = stream;
      await _videoElement.play(); // Bắt buộc phải gọi play() trên web để hình ảnh không bị đen

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Trình duyệt từ chối hoặc lỗi phần cứng:\n$e";
        });
      }
    }
  }

  @override
  void dispose() {
    // Tắt camera khi thoát màn hình
    final stream = _videoElement.srcObject as html.MediaStream?;
    stream?.getTracks().forEach((track) => track.stop());
    _videoElement.srcObject = null;
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (!_isInitialized) return;

    try {
      // Dùng thẻ <canvas> để vẽ lại khung hình hiện tại của <video>
      final canvas = html.CanvasElement(
        width: _videoElement.videoWidth,
        height: _videoElement.videoHeight,
      );
      final ctx = canvas.context2D;
      ctx.drawImage(_videoElement, 0, 0);

      // Chuyển ảnh thành base64 (chất lượng 0.9)
      final base64Image = canvas.toDataUrl('image/jpeg', 0.9);

      if (mounted) {
        // Trả về chuỗi base64 cho màn hình Check-in
        Navigator.pop(context, base64Image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
        
        if (mounted) {
          Navigator.pop(context, base64Image);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan License Plate (Pure Web)'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 4 / 3, // Tỉ lệ phổ biến của webcam
                            child: HtmlElementView(viewType: _viewType),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        color: Colors.black87,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _captureImage,
                                  icon: const Icon(Icons.camera_alt, size: 32),
                                  label: const Text('Capture', style: TextStyle(fontSize: 20)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library, color: Colors.white70),
                              label: const Text('Tải ảnh từ máy tính để Test API', style: TextStyle(color: Colors.white70)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}
