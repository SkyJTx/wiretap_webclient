import 'package:flutter/widgets.dart';
import 'bloc_widget.dart';
import '../../state_manager/cubit.dart';

class BlocBuilder<B extends Cubit<S>, S> extends BlocWidget<B, S> {
  final bool Function(S previous, S current)? callWhen;
  final Widget Function(BuildContext context, S state) builder;

  const BlocBuilder({
    super.key,
    super.bloc,
    this.callWhen,
    required this.builder,
  });

  @override
  bool buildWhen(S previous, S current) {
    return callWhen?.call(previous, current) ?? super.buildWhen(previous, current);
  }

  @override
  Widget build(BuildContext context, S state) {
    return builder(context, state);
  }
}