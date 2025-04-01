import 'dart:async';

import 'package:wiretap_webclient/constant/error.dart';

typedef Emitter<T> = void Function(T value);

class Cubit<State> {
  late bool stale;

  final _stateController = StreamController<State>.broadcast();

  late final Stream<State> _states;
  late final StreamSubscription<State> _stateSubscription;

  Stream<State> get states => _stateController.stream.asBroadcastStream();

  State? _state;
  State? _prevState;
  State get state => _state!;
  State get prevState => _prevState!;

  Cubit(State initialState) {
    _states = _stateController.stream.asBroadcastStream();
    _stateSubscription = _states.listen((state) {
      _prevState = _state;
      _state = state;
    });

    _stateController.add(initialState);

    stale = false;
  }

  void emit(State state) {
    if (stale) {
      throw unknownClientError('Cubit is closed');
    }
    _stateController.add(state);
  }

  Future<void> close() async {
    await _stateController.close();
    await _stateSubscription.cancel();
    stale = true;
  }
}
