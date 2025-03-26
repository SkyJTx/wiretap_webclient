import 'package:flutter/widgets.dart';
import 'bloc_listener.dart';

class MultiBlocListener extends StatelessWidget {
  final List<BlocListener Function(Widget child)> listeners;
  final Widget? child;

  const MultiBlocListener({
    super.key,
    required this.listeners,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget? result = child;
    for (final listener in listeners.reversed) {
      result = listener(result ?? const SizedBox.shrink());
    }
    return result ?? const SizedBox.shrink();
  }
}
