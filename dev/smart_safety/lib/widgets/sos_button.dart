import 'package:flutter/material.dart';
import 'package:smart_community_safety/utils/constants.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SOSButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: AppConstants.sosButtonSize,
        height: AppConstants.sosButtonSize,
        child: FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: const Icon(Icons.sos, size: 32), // ✅ BUILT-IN SOS ICON!
          splashColor: Colors.redAccent.withOpacity(0.5),
          elevation: 6,
        ),
      ),
    );
  }
}