import 'package:flutter/widgets.dart';
import 'bloc_provider.dart';

class MultiBlocProvider extends StatelessWidget {
  final List<BlocProvider Function(Widget child)> providers;
  final Widget child;

  const MultiBlocProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    for (final provider in providers.reversed) {
      result = provider(result);
    }
    return result;
  }
}
