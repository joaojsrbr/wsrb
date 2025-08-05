import 'package:app_wsrb_jsr/app/utils/custom_states.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

mixin SubscriptionsMixin<T extends StatefulWidget> on State<T> {
  final Subscriptions subscriptions = Subscriptions();

  @override
  void dispose() {
    super.dispose();
    subscriptions.cancelAll();
  }
}

mixin SubscriptionsByStateArgumentMixin<T extends StatefulWidget, A extends Object>
    on StateByArgument<T, A> {
  final Subscriptions subscriptions = Subscriptions();

  @override
  void dispose() {
    super.dispose();
    subscriptions.cancelAll();
  }
}
