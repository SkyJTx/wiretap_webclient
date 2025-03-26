import 'dart:async';

import 'package:flutter/widgets.dart';
import '../bloc_inherited_widget.dart';
import '../cubit.dart';

class BlocProvider<B extends Cubit> extends StatefulWidget {
  final B bloc;
  final FutureOr<void> Function(B bloc)? dispose;
  final Widget child;

  const BlocProvider({
    super.key,
    required this.bloc,
    this.dispose,
    required this.child,
  });

  static B of<B extends Cubit>(BuildContext context, {bool listen = true}) {
    return BlocInheritedWidget.of<B>(context, listen: listen);
  }

  static B? maybeOf<B extends Cubit>(BuildContext context, {bool listen = true}) {
    return BlocInheritedWidget.maybeOf<B>(context, listen: listen);
  }

  @override
  State<BlocProvider<B>> createState() => BlocProviderState<B>();
}

class BlocProviderState<B extends Cubit> extends State<BlocProvider<B>> {
  B? bloc;
  Stream? states;
  StreamSubscription? subscription;

  @override
  void didChangeDependencies() {
    if (bloc == null) {
      bloc ??= widget.bloc;
      states ??= bloc?.states;
      subscription ??= states?.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.dispose?.call(bloc!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocInheritedWidget<B>(bloc: bloc!, child: widget.child);
  }
}
