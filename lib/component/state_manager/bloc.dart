import 'dart:async';

import 'cubit.dart';

export 'cubit.dart' show Emitter;

typedef EventCallback<T, Q> = FutureOr<void> Function(T event, void Function(Q) emit);

abstract class Bloc<Event, State> extends Cubit<State> {
  final _eventController = StreamController<Event>.broadcast();
  
  late final Stream<Event> _events;
  late final StreamSubscription<Event> _eventSubscription;
  Completer<void>? _eventCompleter;

  final Map<Type, EventCallback<Event, State>> _eventCallbacks = {};

  Bloc(super.initialState, {bool sequential = false}) {
    _events = _eventController.stream.asBroadcastStream();
    _eventSubscription = _events.listen((event) async {
      final callback = _eventCallbacks[event.runtimeType];
      if (callback != null) {
        if (sequential) {
          await _eventCompleter?.future;
          _eventCompleter = Completer<void>();
          await callback(event, emit);
          _eventCompleter?.complete();
        } else {
          callback(event, emit);
        }
      }
    });
  }

  void on<T extends Event>(EventCallback<T, State> callback) {
    _eventCallbacks[T] = (event, emit) => callback(event as T, emit);
  }

  void add(Event event) {
    _eventController.add(event);
  }

  @override
  Future<void> close() async {
    await _eventSubscription.cancel();
    await _eventController.close();

    super.close();
  }
}
