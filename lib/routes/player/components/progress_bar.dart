import 'package:flutter/material.dart';
import 'package:music/utils/styles.dart';

///Полоса прогресса воспроизведения
class ProgressBar extends StatefulWidget {
  ///Продолжительность в секундах
  final int max;

  ///Текущее значение в секундах
  final int value;

  ///Действие для перемотки плеера
  final void Function(int)? onSeeking;

  const ProgressBar({
    super.key,
    required this.max,
    required this.value,
    this.onSeeking,
  });

  @override
  State<StatefulWidget> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  ///Значение в секундах текущего положения ползунка
  int? _value;
  int? _start;

  ///Получить время в секундах по позиции нажатия на полосу прогресса
  int _getRelative(BuildContext context, Offset position) {
    final box = context.findRenderObject() as RenderBox;
    final value = (position.dx / box.size.width * widget.max).floor();
    if (value < 0) {
      return 0;
    } else if (value > widget.max) {
      return widget.max;
    }

    return (position.dx / box.size.width * widget.max).floor();
  }

  ///Выполнить перемотку плеера
  void _seek(BuildContext context, Offset position) {
    widget.onSeeking?.call(_getRelative(context, position));
  }

  ///Начать перетаскивание ползунка
  void _startSeek(Offset position) {
    if (widget.max <= 0) return;

    setState(() {
      _start = _getRelative(context, position);
      _value = widget.value;
    });
  }

  void _updateSeek(Offset position) {
    if (_value == null || _start == null) return;

    final p = _getRelative(context, position);
    setState(() {
      _value = (_value! + p - _start!).clamp(0, widget.max);
      _start = p;
    });
  }

  ///Закончить перетаскивание ползунка
  void _endSeek() {
    if (_value == null) return;

    widget.onSeeking?.call(_value!);
    setState(() {
      _value = null;
      _start = null;
    });
  }

  double? get _current {
    if (_value != null) {
      return _value! / widget.max;
    } else if (widget.max > 0) {
      return widget.value / widget.max;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _seek(context, d.localPosition),
          onHorizontalDragStart: (d) => _startSeek(d.localPosition),
          onHorizontalDragUpdate: (d) => _updateSeek(d.localPosition),
          onHorizontalDragEnd: (_) => _endSeek(),
          onHorizontalDragCancel: _endSeek,
          child: Container(
            height: 8,
            width: double.maxFinite,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: scheme.inversePrimary),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _current,
              child: ColoredBox(color: scheme.primary),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(msLabel(_value ?? widget.value)),
              Text(msLabel(widget.max)),
            ],
          ),
        )
      ],
    );
  }
}
