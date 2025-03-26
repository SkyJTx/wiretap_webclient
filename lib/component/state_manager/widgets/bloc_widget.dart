// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'bloc_provider.dart';
import '../../state_manager/cubit.dart';

abstract class BlocWidget<B extends Cubit<S>, S> extends StatefulWidget {
  final B? bloc;
  final Widget? child;

  const BlocWidget({super.key, this.bloc, this.child});

  bool listenWhen(S previous, S current) => previous != current;

  FutureOr<void> listen(BuildContext context, S state) {}

  bool buildWhen(S previous, S current) => previous != current;

  Widget build(BuildContext context, S state) {
    return child ?? const SizedBox.shrink();
  }

  @override
  State<BlocWidget<B, S>> createState() => _BlocState<B, S>();
}

class _BlocState<B extends Cubit<S>, S> extends State<BlocWidget<B, S>> {
  B? _bloc;
  final StreamController<S> _stateController = StreamController<S>();
  Stream<S>? _outerStateStream;
  StreamSubscription<S>? _outerStateSubscription;

  S? _currState;
  S? _prevState;

  @override
  void didChangeDependencies() {
    if (_bloc == null) {
      final b = widget.bloc ?? BlocProvider.of<B>(context);
      _bloc = b;
      _currState = _bloc!.state;
      _outerStateStream ??= _bloc!.states;
      _outerStateSubscription ??= _outerStateStream?.listen((state) {
        _prevState = _currState;
        _currState = state;
        if (_prevState != null) {
          if (widget.buildWhen(_prevState! as S, _currState! as S)) {
            _stateController.add(state);
          }
          if (widget.listenWhen(_prevState! as S, _currState! as S)) {
            if (!context.mounted) return;
            widget.listen(context, state);
          }
        }
      });
      _stateController.add(_bloc!.state);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: _stateController.stream,
      builder: (context, snapshot) {
        if (_bloc!.stale) {
          throw StateError('Bloc is closed');
        }
        if (snapshot.hasData) {
          return widget.build(context, snapshot.data! as S);
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _outerStateSubscription?.cancel();
    _stateController.close();
    super.dispose();
  }
}
