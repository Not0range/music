import 'package:flutter/material.dart';

class PlayingIcon extends StatefulWidget {
  final bool animated;

  const PlayingIcon({super.key, this.animated = false});

  @override
  State<StatefulWidget> createState() => _PlayingIconState();
}

class _PlayingIconState extends State<PlayingIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this, upperBound: 6, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PlayingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated != oldWidget.animated) {
      if (widget.animated) {
        _controller.repeat();
      } else {
        _controller.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _builder(double factor) {
    return FractionallySizedBox(
      alignment: Alignment.bottomCenter,
      heightFactor: factor,
      child: Container(
        width: 5,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _controller.value;
    final factors = [
      v <= 3 ? (v + 1) * 0.25 : 1.75 - v * 0.25,
      v <= 3 ? 1 - v * 0.25 : 0.25 + (v - 3) * 0.25,
      v <= 2
          ? (v + 2) * 0.25
          : v <= 5
              ? 1.5 - v * 0.25
              : v * 0.25 - 1,
      v <= 2
          ? 0.75 - v * 0.25
          : v <= 5
              ? (v - 1) * 0.25
              : 2.25 - v * 0.25
    ];
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.5),
      child: FractionallySizedBox(
        heightFactor: 0.5,
        widthFactor: 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _builder(factors[0]),
            _builder(factors[1]),
            _builder(factors[2]),
            _builder(factors[3]),
          ],
        ),
      ),
    );
  }
}
