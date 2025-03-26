import 'package:flutter/widgets.dart';
import 'cubit.dart';

class BlocInheritedWidget<B extends Cubit> extends InheritedWidget {
  final B bloc;

  const BlocInheritedWidget({super.key, required this.bloc, required super.child});

  static B of<B extends Cubit>(BuildContext context, {bool listen = true}) {
    final provider =
        listen
            ? context.dependOnInheritedWidgetOfExactType<BlocInheritedWidget<B>>()
            : context.getInheritedWidgetOfExactType<BlocInheritedWidget<B>>();
    if (provider == null) {
      throw Exception(
        'BlocProvider.of() called with a context that does not contain a Bloc of type $B.',
      );
    }
    return provider.bloc;
  }

  static B? maybeOf<B extends Cubit>(BuildContext context, {bool listen = true}) {
    try {
      return of<B>(context, listen: listen);
    } catch (_) {
      return null;
    }
  }

  @override
  bool updateShouldNotify(BlocInheritedWidget<B> oldWidget) {
    return !bloc.stale;
  }
}
