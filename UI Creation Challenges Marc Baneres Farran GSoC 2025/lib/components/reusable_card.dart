import 'package:flutter/material.dart';

class ReusableCard extends StatefulWidget {
  const ReusableCard(
      {super.key, required this.colour, this.cardChild, required this.onPress});
  final Color colour;
  final Widget? cardChild;
  final Function() onPress;

  @override
  State<ReusableCard> createState() => _ReusableCardState();
}

class _ReusableCardState extends State<ReusableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPress();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        transform: _isPressed
            ? Matrix4.translationValues(0, 2, 0)
            : Matrix4.translationValues(0, 0, 0),
        decoration: BoxDecoration(
          color: _isPressed ? widget.colour.withOpacity(0.7) : widget.colour,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: _isPressed ? 0 : 1,
              blurRadius: _isPressed ? 2 : 5,
              offset: _isPressed ? const Offset(0, 1) : const Offset(0, 3),
            ),
          ],
        ),
        child: widget.cardChild,
      ),
    );
  }
}
