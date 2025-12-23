import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Habit Completion Animation
/// Success animation with checkmark and particles
class HabitCompletionAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const HabitCompletionAnimation({super.key, this.onComplete});

  @override
  State<HabitCompletionAnimation> createState() =>
      _HabitCompletionAnimationState();
}

class _HabitCompletionAnimationState extends State<HabitCompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _checkController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOut,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _controller.forward();
    await _checkController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _checkController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: ParticlePainter(
                progress: _particleController.value,
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),

        // Circle with checkmark
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _checkAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CheckmarkPainter(
                    progress: _checkAnimation.value,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Particle Painter for completion effect
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final math.Random random = math.Random(42);

  ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = 50 + (progress * 50);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final opacity = 1.0 - progress;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4 * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Checkmark Painter
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final checkStart = Offset(size.width * 0.25, size.height * 0.5);
    final checkMiddle = Offset(size.width * 0.45, size.height * 0.7);
    final checkEnd = Offset(size.width * 0.75, size.height * 0.3);

    if (progress < 0.5) {
      // First part of checkmark
      final currentProgress = progress * 2;
      path.moveTo(checkStart.dx, checkStart.dy);
      path.lineTo(
        checkStart.dx + (checkMiddle.dx - checkStart.dx) * currentProgress,
        checkStart.dy + (checkMiddle.dy - checkStart.dy) * currentProgress,
      );
    } else {
      // Complete first part and animate second part
      final currentProgress = (progress - 0.5) * 2;
      path.moveTo(checkStart.dx, checkStart.dy);
      path.lineTo(checkMiddle.dx, checkMiddle.dy);
      path.lineTo(
        checkMiddle.dx + (checkEnd.dx - checkMiddle.dx) * currentProgress,
        checkMiddle.dy + (checkEnd.dy - checkMiddle.dy) * currentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Show Habit Completion Animation
void showHabitCompletionAnimation(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: HabitCompletionAnimation(
            onComplete: () => overlayEntry.remove(),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
