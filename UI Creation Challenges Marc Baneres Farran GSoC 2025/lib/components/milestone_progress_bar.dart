import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/animated_milestone_circle.dart';

class MilestoneProgressBar extends StatelessWidget {
  final int targetProgress;
  final int displayProgress;
  final int totalMilestones;
  final List<String> milestoneTexts;

  const MilestoneProgressBar({
    Key? key,
    required this.targetProgress,
    required this.displayProgress,
    this.totalMilestones = 4,
    required this.milestoneTexts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressRow(),
        const SizedBox(height: 8),
        _buildTextsRow(),
      ],
    );
  }

  Widget _buildProgressRow() {
    List<Widget> children = [];

    children.add(
      const Expanded(
        flex: 0,
        child: SizedBox(),
      ),
    );

    for (int i = 0; i < totalMilestones; i++) {
      children.add(
        Expanded(
          flex: 3,
          child: AnimatedMilestoneCircle(
            milestoneNumber: i + 1,
            filled: displayProgress >= i + 1,
          ),
        ),
      );

      if (i < totalMilestones - 1) {
        children.add(
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool segmentCompleted = targetProgress > i + 1;
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: 4,
                      color: Colors.grey,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: segmentCompleted ? constraints.maxWidth : 0,
                      height: 4,
                      color: Colors.black,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    }

    children.add(
      const Expanded(
        flex: 0,
        child: SizedBox(),
      ),
    );

    return Row(children: children);
  }

  Widget _buildTextsRow() {
    List<Widget> children = [];

    children.add(
      const Expanded(
        flex: 0,
        child: SizedBox(),
      ),
    );

    for (int i = 0; i < totalMilestones; i++) {
      children.add(
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              milestoneTexts[i],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ),
      );

      if (i < totalMilestones - 1) {
        children.add(
          const Expanded(
            flex: 2,
            child: SizedBox(),
          ),
        );
      }
    }

    children.add(
      const Expanded(
        flex: 0,
        child: SizedBox(),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
