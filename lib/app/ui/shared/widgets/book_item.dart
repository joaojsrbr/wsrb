import 'package:app_wsrb_jsr/app/core/constants/app.dart';
import 'package:app_wsrb_jsr/app/routes/routes.dart';
import 'package:app_wsrb_jsr/app/models/book.dart';
import 'package:app_wsrb_jsr/app/ui/book_information/arguments/book_information_args.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookItem extends StatelessWidget {
  const BookItem({
    super.key,
    required this.item,
  });

  final Book item;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context).copyWith(
      colorScheme: item.bookColorScheme
          ?.copyWith(brightness: Theme.of(context).brightness),
    );
    final textTheme = themeData.textTheme;
    final borderRadius = BorderRadius.circular(12);

    return Theme(
      data: themeData,
      child: Container(
        padding: const EdgeInsetsDirectional.all(4),
        height: 160,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 4,
          margin: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: borderRadius.copyWith(
                      topRight: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    child: _ImageWidget(item),
                  ),
                  Expanded(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 12,
                            right: 12,
                            bottom: 8,
                          ),
                          child: Text(
                            item.title,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: borderRadius,
                  splashFactory: InkRipple.splashFactory,
                  onTap: () async {
                    await context.push(
                      RouteName.BOOKINFO,
                      extra: BookInformationArgs(book: item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class BookItem extends StatelessWidget {
//   const BookItem({required this.item, super.key});

//   final Book item;

//   @override
//   Widget build(BuildContext context) {
//     final themeData = Theme.of(context);
//     final textTheme = themeData.textTheme;

//     final state = context.findAncestorStateOfType<HomeUtils>();

//     return OpenContainerWidgetWrapper(
//       closedElevation: 0,
//       openElevation: 0,
//       clipBehavior: Clip.hardEdge,
//       borderRadius: BorderRadius.circular(8),
//       openColor: themeData.cardColor,
//       closedColor: themeData.cardColor,
//       transitionDuration: const Duration(milliseconds: 500),
//       onClosed: (data) async {
//         await Future.delayed(const Duration(milliseconds: 500));
//         state?.disableScroll(false);
//       },
//       arguments: BookInformationArgs(book: item),
//       widgetBuilder: (context) => Stack(
//         fit: StackFit.expand,
//         children: [
//           _ImageWidget(item),
//           Container(
//             alignment: Alignment.bottomCenter,
//             padding: const EdgeInsets.all(8),
//             child: Text(
//               item.title,
//               maxLines: 2,
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               style: textTheme.titleLarge?.copyWith(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               splashFactory: InkRipple.splashFactory,
//               onTap: () async {
//                 final result = await OpenContainerWidgetWrapper.action(context);
//                 state?.disableScroll(true);

//                 if (result is Failure && context.mounted) {
//                   result.snackBar(context);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ImageWidget extends StatelessWidget {
  const _ImageWidget(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    // final themeData = Theme.of(context);

    final Widget imageWidget = SizedBox(
      width: 125,
      child: CachedNetworkImage(
        errorWidget: (context, url, obj) {
          return Image(
            image: ResizeImage.resizeIfNeeded(
              375,
              450,
              App.DEFAULT_IMAGE_PLACEHOLDER,
            ),
            alignment: Alignment.center,
            height: 200,
            fit: BoxFit.cover,
          );
        },
        alignment: FractionalOffset.center,
        imageUrl: book.originalImage,
        cacheKey: book.title,
        memCacheHeight: 450,
        memCacheWidth: 350,
        fit: BoxFit.cover,
      ),
    );

    return imageWidget;
  }
}
