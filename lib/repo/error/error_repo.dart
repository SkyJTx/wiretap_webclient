import 'dart:async';

import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

class ErrorRepo {
  final errorStreamController = StreamController<Object?>.broadcast();
  StreamSubscription<Object?>? errorStreamSubscription;

  ErrorRepo.createInstance() {
    errorStreamSubscription = errorStreamController.stream.listen((error) {
      final context = UiRepo().context;
      if (!context.mounted) return;
      UiRepo().showErrorDialog(context, error.toString());
    });
  }

  static ErrorRepo? _instance;

  factory ErrorRepo() {
    _instance ??= ErrorRepo.createInstance();
    return _instance!;
  }

  void addError(Object? error) {
    errorStreamController.add(error);
  }

  void dispose() {
    errorStreamSubscription?.cancel();
    errorStreamSubscription = null;
    errorStreamController.close();
  }
}
