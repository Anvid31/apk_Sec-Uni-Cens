import 'dart:async';
import 'package:flutter/material.dart';

class RepeatingIconButton extends StatefulWidget {
  final Icon icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;

  const RepeatingIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
    this.constraints,
  }) : super(key: key);

  @override
  State<RepeatingIconButton> createState() => _RepeatingIconButtonState();
}

class _RepeatingIconButtonState extends State<RepeatingIconButton> {
  Timer? _timer;

  void _startTimer() {
    if (widget.onPressed == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      widget.onPressed?.call();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startTimer(),
      onLongPressEnd: (_) => _stopTimer(),
      onLongPressCancel: () => _stopTimer(),
      child: IconButton(
        icon: widget.icon,
        onPressed: widget.onPressed,
        padding: widget.padding,
        constraints: widget.constraints,
      ),
    );
  }
}
