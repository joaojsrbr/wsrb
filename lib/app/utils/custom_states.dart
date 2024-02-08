import 'package:app_wsrb_jsr/app/core/extensions/custom_extensions/state_extensions.dart';
import 'package:flutter/widgets.dart';

abstract class StateByArgument<T extends StatefulWidget, A extends Object>
    extends State<T> {
  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    assert(argument is A);
    return buildByArgument(context, argument as A);
  }

  A argument() {
    Object? argument;
    if (!mounted) {
      addPostFrameCallback((data) {
        argument = ModalRoute.of(context)?.settings.arguments;
      });
    } else {
      argument = ModalRoute.of(context)?.settings.arguments;
    }
    assert(argument is A);
    return argument as A;
  }

  Widget buildByArgument(BuildContext context, A argument);
}
