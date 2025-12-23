import 'package:flutter/material.dart';

/// XP Award Animation
/// Animated XP award display with particles and number animation
class XpAwardAnimation extends StatefulWidget {
  final int xpAmount;
  final bool hasBonus;
  final String? bonusType;
  final VoidCallback? onComplete;

  const XpAwardAnimation({
    super.key,
    required this.xpAmount,
    this.hasBonus = false,
    this.bonusType,
    this.onComplete,
  });

  @override
  State<XpAwardAnimation> createState() => _XpAwardAnimationState();
}

class _XpAwardAnimationState extends State<XpAwardAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _numberController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _numberAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _numberController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _numberAnimation = IntTween(begin: 0, end: widget.xpAmount).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _fadeController.forward();
    await Future.wait([
      _scaleController.forward(),
      _numberController.forward(),
    ]);

    await Future.delayed(const Duration(seconds: 2));

    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  AnimatedBuilder(
                    animation: _numberAnimation,
                    builder: (context, child) {
                      return Text(
                        '+${_numberAnimation.value} XP',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (widget.hasBonus && widget.bonusType != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🎉 ${widget.bonusType} Bonus!',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Show XP Award Animation as overlay
void showXpAwardAnimation(
  BuildContext context, {
  required int xpAmount,
  bool hasBonus = false,
  String? bonusType,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: XpAwardAnimation(
            xpAmount: xpAmount,
            hasBonus: hasBonus,
            bonusType: bonusType,
            onComplete: () => overlayEntry.remove(),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
