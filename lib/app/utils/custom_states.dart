import 'package:flutter/widgets.dart';

abstract class StateByArgument<T extends StatefulWidget, A extends Object>
    extends State<T> {
  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    assert(argument is A);
    return buildByArgument(context, argument as A);
  }

  Widget buildByArgument(BuildContext context, A argument);
}
