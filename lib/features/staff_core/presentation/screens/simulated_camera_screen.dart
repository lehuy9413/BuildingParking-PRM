import 'package:flutter/material.dart';
import 'dart:async';

class SimulatedCameraScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const SimulatedCameraScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<SimulatedCameraScreen> createState() => _SimulatedCameraScreenState();
}

class _SimulatedCameraScreenState extends State<SimulatedCameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Tự động trả về kết quả sau 2.5 giây mô phỏng
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _isScanning = false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Simulated camera view (dark background)
          Container(color: const Color(0xFF111111)),
          
          // Camera frame
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: _isScanning ? Colors.white54 : Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Positioned(
                          top: _animationController.value * 190,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  if (!_isScanning)
                    const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Subtitle text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              _isScanning ? widget.subtitle : 'Hoàn tất!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
