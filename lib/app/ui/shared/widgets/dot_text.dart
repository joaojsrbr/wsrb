import 'package:flutter/material.dart';

class DotText extends StatelessWidget {
  final String text;
  final Color dotColor;
  final double dotSize;
  final TextStyle? textStyle;
  final double spacing;

  const DotText({
    super.key,
    required this.text,
    this.dotColor = Colors.black,
    this.dotSize = 6.0,
    this.textStyle,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.only(
              top: (textStyle?.fontSize ??
                          DefaultTextStyle.of(context).style.fontSize!) /
                      2 -
                  dotSize / 2,
            ),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: spacing),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: textStyle ?? DefaultTextStyle.of(context).style,
        ),
      ],
    );
  }
}
