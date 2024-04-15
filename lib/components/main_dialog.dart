import 'package:flutter/material.dart';

class MainDialog extends StatelessWidget {
  final String text;
  final List<MainDialogAction> actions;

  const MainDialog({
    super.key,
    required this.text,
    required this.actions,
  });

  Color? _color(BuildContext context, MainDialogActionType type) {
    switch (type) {
      case MainDialogActionType.danger:
        return Theme.of(context).colorScheme.error;
      default:
        return null;
    }
  }

  Widget _builder(BuildContext context, ThemeData theme, ButtonStyle style,
      MainDialogAction item) {
    final s = theme.textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: OutlinedButton(
          style: style,
          onPressed: () {
            Navigator.pop(context);
            item.action?.call();
          },
          child: SizedBox(
            child: Text(item.text,
                textAlign: TextAlign.center,
                style: s?.copyWith(
                  color: _color(context, item.type),
                )),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final t = Theme.of(context);
    final style = ButtonStyle(
        fixedSize: MaterialStatePropertyAll(Size.fromWidth(w)),
        padding: const MaterialStatePropertyAll(EdgeInsets.all(12)),
        backgroundColor: MaterialStatePropertyAll(t.scaffoldBackgroundColor),
        side: const MaterialStatePropertyAll(BorderSide.none));

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: w,
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: t.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              text,
              style: t.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          ...actions.map((e) => _builder(context, t, style, e)),
          SizedBox(height: MediaQuery.paddingOf(context).bottom)
        ],
      ),
    );
  }
}

class MainDialogAction {
  final String text;
  final VoidCallback? action;
  final MainDialogActionType type;

  MainDialogAction(this.text, this.action, this.type);
}

enum MainDialogActionType { common, danger }
