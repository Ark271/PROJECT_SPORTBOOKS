import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    // KhÃ´ng dÃ¹ng package ngoÃ i Ä‘á»ƒ trÃ¡nh pháº£i thÃªm dependency.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, t, __) {
        final color = Color.lerp(base, highlight, (t * 2) % 1)!;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        );
      },
      onEnd: () {},
    );
  }
}

class BookGridSkeleton extends StatelessWidget {
  final bool embed;
  const BookGridSkeleton({super.key, this.embed = false});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cross = w >= 1200
        ? 6
        : w >= 900
            ? 4
            : w >= 600
                ? 3
                : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: 8,
      shrinkWrap: embed,
      physics: embed ? const NeverScrollableScrollPhysics() : null,
      itemBuilder: (context, i) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                SkeletonBox(
                  height: 120,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(height: 12),
                SkeletonBox(height: 14, width: double.infinity),
                SizedBox(height: 6),
                SkeletonBox(height: 12, width: 120),
                SizedBox(height: 6),
                SkeletonBox(height: 12, width: 90),
                Spacer(),
                SkeletonBox(
                  height: 36,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


