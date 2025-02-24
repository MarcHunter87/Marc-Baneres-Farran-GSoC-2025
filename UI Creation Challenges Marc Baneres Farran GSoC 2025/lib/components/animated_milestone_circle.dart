import 'package:flutter/material.dart';

class AnimatedMilestoneCircle extends StatelessWidget {
  final int milestoneNumber;
  final bool filled;

  const AnimatedMilestoneCircle({
    Key? key,
    required this.milestoneNumber,
    required this.filled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? Colors.black : Colors.grey,
            ),
          ),
          Center(
            child: Text(
              '$milestoneNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
