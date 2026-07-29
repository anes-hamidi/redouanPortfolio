import 'package:flutter/material.dart';

/// A clean, stateful hover builder wrapper that provides reactive mouse hover states
class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final MouseCursor cursor;

  const HoverBuilder({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.basic,
  });

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}
