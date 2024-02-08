import 'package:flutter/material.dart';

class LibraryDestination extends StatefulWidget {
  const LibraryDestination({super.key});

  @override
  State<LibraryDestination> createState() => LibraryeDestinationState();
}

class LibraryeDestinationState extends State<LibraryDestination>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
  }
}
