import 'package:flutter/material.dart';

/// Collection d'animations réutilisables pour l'application Klipr
class KliprAnimations {
  
  /// Animation de rotation pour les boutons de refresh
  static Animation<double> createRefreshRotation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Animation de refresh avec effet de rebond
  static Animation<double> createRefreshBounce(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  /// Animation de gradient pour les éléments de loading
  static Animation<double> createLoadingGradient(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  /// Animation de scale pour les cartes (effet de rebond)
  static Animation<double> createCardScale(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  /// Animation de fade pour les cartes
  static Animation<double> createCardFade(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));
  }

  /// Animation de slide pour les cartes (glissement depuis le bas)
  static Animation<Offset> createCardSlide(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));
  }

  /// Animation de pulse pour les indicateurs de live
  static Animation<double> createPulse(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Animation de shimmer pour les états de chargement
  static Animation<double> createShimmer(AnimationController controller) {
    return Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Animation de bounce pour les boutons pressés
  static Animation<double> createBounce(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    ));
  }

  /// Animation de wave pour les indicateurs de son
  static Animation<double> createWave(AnimationController controller, double delay) {
    return Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(delay, delay + 0.3, curve: Curves.easeInOut),
    ));
  }

  /// Animation de typing pour les indicateurs de chat
  static Animation<double> createTyping(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
  }

  /// Animation de slide up pour les modales
  static Animation<Offset> createSlideUp(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));
  }
}

/// Widget builder pour les animations de cartes avec tous les effets
class AnimatedCardBuilder extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final bool enableScale;
  final bool enableFade;
  final bool enableSlide;

  const AnimatedCardBuilder({
    super.key,
    required this.child,
    required this.controller,
    this.enableScale = true,
    this.enableFade = true,
    this.enableSlide = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (enableSlide) {
      final slideAnimation = KliprAnimations.createCardSlide(controller);
      result = SlideTransition(
        position: slideAnimation,
        child: result,
      );
    }

    if (enableScale) {
      final scaleAnimation = KliprAnimations.createCardScale(controller);
      result = ScaleTransition(
        scale: scaleAnimation,
        child: result,
      );
    }

    if (enableFade) {
      final fadeAnimation = KliprAnimations.createCardFade(controller);
      result = FadeTransition(
        opacity: fadeAnimation,
        child: result,
      );
    }

    return result;
  }
}

/// Widget pour l'animation de pulse des indicateurs live
class PulsingIndicator extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;

  const PulsingIndicator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = KliprAnimations.createPulse(_controller);
    
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enabled ? _animation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}

/// Widget personnalisé pour l'indicateur de refresh avec animations
class RefreshIndicatorWidget extends StatefulWidget {
  final bool isRefreshing;
  final VoidCallback? onTap;

  const RefreshIndicatorWidget({
    super.key,
    required this.isRefreshing,
    this.onTap,
  });

  @override
  State<RefreshIndicatorWidget> createState() => _RefreshIndicatorWidgetState();
}

class _RefreshIndicatorWidgetState extends State<RefreshIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotationAnimation = KliprAnimations.createRefreshRotation(_rotationController);
    _scaleAnimation = KliprAnimations.createRefreshBounce(_scaleController);
    
    if (widget.isRefreshing) {
      _startRefreshAnimation();
    }
  }

  @override
  void didUpdateWidget(RefreshIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing != oldWidget.isRefreshing) {
      if (widget.isRefreshing) {
        _startRefreshAnimation();
      } else {
        _stopRefreshAnimation();
      }
    }
  }

  void _startRefreshAnimation() {
    _scaleController.forward();
    _rotationController.repeat();
  }

  void _stopRefreshAnimation() {
    _scaleController.reverse();
    _rotationController.stop();
    _rotationController.reset();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isRefreshing
                        ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                        : [Colors.grey.shade600, Colors.grey.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isRefreshing
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}