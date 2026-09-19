import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

/// A single horizontal-scroll behaviour for every long list of choice chips.
/// It keeps controls reachable on narrow screens instead of wrapping or
/// truncating the final choices.
class HorizontalChoiceChipScroller extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const HorizontalChoiceChipScroller({
    super.key,
    required this.children,
    this.height = 40,
    this.spacing = 8,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          primary: false,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: padding,
          itemCount: children.length,
          separatorBuilder: (_, _) => SizedBox(width: spacing),
          itemBuilder: (_, index) => children[index],
        ),
      ),
    );
  }
}
