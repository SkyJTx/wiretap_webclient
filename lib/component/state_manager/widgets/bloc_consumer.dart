import 'dart:async';

import 'package:flutter/widgets.dart';
import 'bloc_widget.dart';
import '../../state_manager/cubit.dart';

class BlocConsumer<B extends Cubit<S>, S> extends BlocWidget<B, S> {
  final bool Function(S previous, S current)? callListenWhen;
  final bool Function(S previous, S current)? callBuildWhen;
  final void Function(BuildContext context, S state) listener;
  final Widget Function(BuildContext context, S state) builder;

  const BlocConsumer({
    super.key,
    super.bloc,
    this.callListenWhen,
    required this.listener,
    this.callBuildWhen,
    required this.builder,
  });

  @override
  bool listenWhen(S previous, S current) {
    return callListenWhen?.call(previous, current) ?? super.listenWhen(previous, current);
  }

  @override
  FutureOr<void> listen(BuildContext context, S state) {
    listener(context, state);
  }

  @override
  bool buildWhen(S previous, S current) {
    return callBuildWhen?.call(previous, current) ?? super.buildWhen(previous, current);
  }

  @override
  Widget build(BuildContext context, S state) {
    return builder(context, state);
  }
}
