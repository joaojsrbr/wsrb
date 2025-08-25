// import 'dart:async';

// import 'package:app_wsrb_jsr/app/ui/home/widgets/home_scope.dart';
// import 'package:app_wsrb_jsr/app/ui/shared/widgets/fade_through_transition_switcher.dart';
// import 'package:app_wsrb_jsr/app/utils/category_helper.dart';
// import 'package:content_library/content_library.dart';
// import 'package:flutter/material.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:provider/provider.dart';

// class BottomMenu<T> extends ImplicitlyAnimatedWidget {
//   const BottomMenu({
//     super.key,
//     required this.child,
//     this.buttons,
//     this.isDismissible = false,
//     required this.bottomMenuController,
//   }) : super(duration: const Duration(milliseconds: 350));

//   final BottomMenuController<T> bottomMenuController;
//   final WidgetBuilder? buttons;
//   final bool isDismissible;
//   final Widget child;

//   static BottomMenuController<T>? menuControllerMaybeOf<T>(BuildContext context) {
//     return _BottomMenuControllerScope.maybeOf(context)?.notifier
//         as BottomMenuController<T>?;
//   }

//   static BottomMenuController<T> menuControllerOf<T>(BuildContext context) {
//     return _BottomMenuControllerScope.of(context).notifier! as BottomMenuController<T>;
//   }

//   @override
//   ImplicitlyAnimatedWidgetState<BottomMenu<T>> createState() => _BottomMenuState<T>();
// }

// class _BottomMenuState<T> extends AnimatedWidgetBaseState<BottomMenu<T>> {
//   late final BottomMenuController<T> _railMenuController;
//   @override
//   void initState() {
//     _railMenuController = widget.bottomMenuController;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _BottomMenuControllerScope(
//       notifier: _railMenuController,
//       child: Builder(
//         builder: (context) {
//           final railMenuController = BottomMenu.menuControllerOf(context);
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 child: Stack(
//                   alignment: Alignment.bottomCenter,
//                   fit: StackFit.expand,
//                   children: [
//                     widget.child,
//                     if (widget.isDismissible && railMenuController.isOpen)
//                       AnimatedModalBarrier(
//                         barrierSemanticsDismissible: railMenuController.isOpen,
//                         color: animation.drive(
//                           ColorTween(
//                             begin: Colors.black54,
//                             end: Colors.black54,
//                           ).chain(CurveTween(curve: Curves.ease)),
//                         ),
//                         onDismiss: () {
//                           final ValueNotifierList valueNotifierList = context
//                               .read<ValueNotifierList>();
//                           valueNotifierList.clear();
//                           railMenuController.close();
//                         },
//                       ),
//                   ],
//                 ),
//               ),

//               AnimatedSize(
//                 reverseDuration: Duration(milliseconds: 450),
//                 duration: Duration(milliseconds: 450),
//                 curve: Curves.fastOutSlowIn,
//                 child: railMenuController.isOpen
//                     ? Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: SizedBox(
//                           width: MediaQuery.sizeOf(context).width,
//                           height: railMenuController.menuSize.height,
//                           child: widget.buttons?.call(context) ?? const LibraryButtons(),
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//               // CustomPopup.builder(
//               //   show: railMenuController.isOpen,
//               //   width: MediaQuery.sizeOf(context).width,
//               //   reverseDuration: const Duration(milliseconds: 250),
//               //   shape: RoundedRectangleBorder(),
//               //   startAnimatedAlignment: Alignment.bottomCenter,
//               //   duration: const Duration(milliseconds: 250),
//               //   height: railMenuController._menuSize.height,
//               //   builder: (context) => Padding(
//               //     padding: const EdgeInsets.symmetric(horizontal: 8),
//               //     child: widget.buttons?.call(context) ?? const _LibraryButtons(),
//               //   ),
//               // ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _railMenuController.dispose();
//     super.dispose();
//   }

//   // @override
//   // void deactivate() {
//   //   _railMenuController.close();
//   //   super.deactivate();
//   // }

//   @override
//   void forEachTween(TweenVisitor<dynamic> visitor) {}
// }

// class _BottomMenuControllerScope extends InheritedNotifier<BottomMenuController> {
//   const _BottomMenuControllerScope({required super.child, required super.notifier});

//   static _BottomMenuControllerScope of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<_BottomMenuControllerScope>()!;
//   }

//   static _BottomMenuControllerScope? maybeOf(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<_BottomMenuControllerScope>();
//   }

//   @override
//   bool updateShouldNotify(_BottomMenuControllerScope oldWidget) {
//     return notifier?.isOpen != oldWidget.notifier?.isOpen ||
//         notifier?.menuSize != oldWidget.notifier?.menuSize;
//   }
// }

// class BottomMenuController<T> extends ChangeNotifier {
//   BottomMenuController({
//     bool opened = false,
//     double minHeight = 50,
//     this.menuSize = const Size(double.infinity, 50),
//     required T initialArgs,
//     this.onClose,
//   }) {
//     _openMenu = opened;
//     setArgs = initialArgs;
//   }

//   void Function(T args)? onClose;

//   final Size menuSize;

//   late T _args;

//   set setArgs(T value) {
//     _args = value;
//   }

//   T get args => _args;

//   void open() {
//     _openMenu = true;
//     notifyListeners();
//   }

//   void close() {
//     _openMenu = false;
//     onClose?.call(args);
//     notifyListeners();
//   }

//   void update() => notifyListeners();

//   void toogle() {
//     _openMenu = !_openMenu;
//     notifyListeners();
//   }

//   bool get isOpen => _openMenu;

//   bool _openMenu = false;
// }
