import 'package:flutter/material.dart';
import 'dart:math' as math;

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;

  const SwipeableCard({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
  }) : super(key: key);

  @override
  SwipeableCardState createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _hasSwiped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_hasSwiped) return;

    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_hasSwiped) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4; // 40% of screen width

    if (_dragOffset.dx.abs() > threshold) {
      // Swipe threshold reached
      _hasSwiped = true;
      
      if (_dragOffset.dx > 0) {
        // Swipe right
        _swipeRight();
      } else {
        // Swipe left
        _swipeLeft();
      }
    } else {
      // Return to center
      _resetPosition();
    }
  }

  void _swipeRight() {
    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / 100,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward().then((_) {
      widget.onSwipeRight?.call();
    });
  }

  void _swipeLeft() {
    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / 100,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward().then((_) {
      widget.onSwipeLeft?.call();
    });
  }

  void _resetPosition() {
    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void swipeRight() {
    if (!_hasSwiped) {
      _hasSwiped = true;
      _dragOffset = Offset(MediaQuery.of(context).size.width, 0);
      _swipeRight();
    }
  }

  void swipeLeft() {
    if (!_hasSwiped) {
      _hasSwiped = true;
      _dragOffset = Offset(-MediaQuery.of(context).size.width, 0);
      _swipeLeft();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate rotation based on drag
    final rotation = _dragOffset.dx / screenWidth * 0.3;
    
    // Calculate opacity for like/nope indicators
    final likeOpacity = _dragOffset.dx > 0 ? (_dragOffset.dx / screenWidth * 2).clamp(0.0, 1.0) : 0.0;
    final nopeOpacity = _dragOffset.dx < 0 ? (-_dragOffset.dx / screenWidth * 2).clamp(0.0, 1.0) : 0.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final currentOffset = _hasSwiped 
            ? Offset(_dragOffset.dx * _animation.value, _dragOffset.dy * _animation.value)
            : _dragOffset;
        
        final currentRotation = _hasSwiped 
            ? _rotationAnimation.value 
            : rotation;
        
        final currentScale = _hasSwiped 
            ? _scaleAnimation.value 
            : 1.0;

        return Transform.translate(
          offset: currentOffset,
          child: Transform.rotate(
            angle: currentRotation,
            child: Transform.scale(
              scale: currentScale,
              child: GestureDetector(
                onTap: widget.onTap,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Stack(
                  children: [
                    // Main card
                    Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: widget.child,
                      ),
                    ),
                    
                    // Like indicator
                    if (likeOpacity > 0)
                      Positioned(
                        top: 50,
                        left: 30,
                        child: Transform.rotate(
                          angle: -math.pi / 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'LIKE',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Nope indicator
                    if (nopeOpacity > 0)
                      Positioned(
                        top: 50,
                        right: 30,
                        child: Transform.rotate(
                          angle: math.pi / 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'NOPE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 