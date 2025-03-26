import 'dart:async';

import 'package:flutter/widgets.dart';
import 'bloc_widget.dart';
import '../../state_manager/cubit.dart';

class BlocListener<B extends Cubit<S>, S> extends BlocWidget<B, S> {
  final bool Function(S previous, S current)? callWhen;
  final void Function(BuildContext context, S state) listener;

  const BlocListener({
    super.key,
    super.bloc,
    this.callWhen,
    required this.listener,
    super.child,
  });

  @override
  bool listenWhen(S previous, S current) {
    return callWhen?.call(previous, current) ?? super.listenWhen(previous, current);
  }

  @override
  FutureOr<void> listen(BuildContext context, S state) {
    listener(context, state);
  }
}
