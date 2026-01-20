import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/assistant/assistant_controller.dart';

class AiOrb extends StatefulWidget {
  const AiOrb({
    super.key,
    required this.state,
    this.onTap,
  });

  final AssistantState state;
  final VoidCallback? onTap;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.92,
      upperBound: 1.05,
    )..value = 1.0;

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didUpdateWidget(covariant AiOrb oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Pulse behaviour
    if (widget.state == AssistantState.listening) {
      _pulseController.duration = const Duration(milliseconds: 1200);
      _pulseController.repeat(reverse: true);
    } else if (widget.state == AssistantState.speaking) {
      _pulseController.duration = const Duration(milliseconds: 900);
      _pulseController.repeat(reverse: true);
    } else if (widget.state == AssistantState.thinking) {
      _pulseController.duration = const Duration(milliseconds: 2000);
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }

    // Shimmer only while thinking
    if (widget.state == AssistantState.thinking) {
      _shimmerController.repeat();
    } else {
      _shimmerController.stop();
      _shimmerController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  double _glowOpacity() {
    switch (widget.state) {
      case AssistantState.listening:
        return 0.55;
      case AssistantState.thinking:
        return 0.35;
      case AssistantState.speaking:
        return 0.65;
      case AssistantState.idle:
      default:
        return 0.18;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseController,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic glow (stronger when alive)
          Container(
            height: 260,
            width: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(_glowOpacity()),
                  blurRadius: 140,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),

          // Shimmer ring (only visible during thinking)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (_, __) {
              final show = widget.state == AssistantState.thinking;
              return Opacity(
                opacity: show ? 0.9 : 0.0,
                child: Transform.rotate(
                  angle: _shimmerController.value * 2 * math.pi,
                  child: Container(
                    height: 238,
                    width: 238,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: AppColors.accent.withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Main orb
          Container(
            height: 210,
            width: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.surface,
                  AppColors.background,
                ],
              ),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.25),
                width: 1.5,
              ),
            ),
          ),

          // Core
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(
                    widget.state == AssistantState.idle ? 0.25 : 0.5,
                  ),
                  blurRadius: 30,
                ),
              ],
            ),
          ),

          // Mic
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(
                widget.state == AssistantState.listening
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
