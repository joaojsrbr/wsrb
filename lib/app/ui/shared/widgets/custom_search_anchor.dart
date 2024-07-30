import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';

typedef CustomSearchAnchorChildBuilder = Widget Function(
    BuildContext context, CustomSearchController controller);

typedef CustomSearchSuggestionsBuilder = FutureOr<Widget> Function(
    BuildContext context, CustomSearchController controller);

typedef CustomSearchViewBuilder = Widget Function(Widget suggestion);

const int _kOpenViewMilliseconds = 600;
const Duration _kOpenViewDuration =
    Duration(milliseconds: _kOpenViewMilliseconds);
const Duration _kAnchorFadeDuration = Duration(milliseconds: 150);
const Curve _kViewFadeOnInterval = Interval(0.0, 1 / 2);
const Curve _kViewIconsFadeOnInterval = Interval(1 / 6, 2 / 6);
const Curve _kViewDividerFadeOnInterval = Interval(0.0, 1 / 6);
const Curve _kViewListFadeOnInterval =
    Interval(133 / _kOpenViewMilliseconds, 233 / _kOpenViewMilliseconds);
// const double _kDisableSearchBarOpacity = 0.38;

class CustomSearchAnchor extends StatefulWidget {
  const CustomSearchAnchor._({
    super.key,
    this.isFullScreen,
    this.searchController,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.dividerWidget,
    this.viewSide,
    this.viewShape,
    this.headerTextStyle,
    this.headerHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    this.viewOnChanged,
    this.viewOnSubmitted,
    required this.builder,
    required this.suggestionsBuilder,
    this.textInputAction,
    this.labelText,
    this.keyboardType,
  });

  factory CustomSearchAnchor({
    Widget? barLeading,
    Iterable<Widget>? barTrailing,
    String? barHintText,
    GestureTapCallback? onTap,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    WidgetStateProperty<double?>? barElevation,
    WidgetStateProperty<Color?>? barBackgroundColor,
    WidgetStateProperty<Color?>? barOverlayColor,
    WidgetStateProperty<BorderSide?>? barSide,
    WidgetStateProperty<RoundedRectangleBorder?>? barShape,
    WidgetStateProperty<EdgeInsetsGeometry?>? barPadding,
    WidgetStateProperty<TextStyle?>? barTextStyle,
    WidgetStateProperty<TextStyle?>? barHintStyle,
    Widget? viewLeading,
    Iterable<Widget>? viewTrailing,
    String? viewHintText,
    Color? viewBackgroundColor,
    Widget? dividerWidget,
    double? viewElevation,
    BorderSide? viewSide,
    RoundedRectangleBorder? viewShape,
    TextStyle? viewHeaderTextStyle,
    TextStyle? viewHeaderHintStyle,
    Color? dividerColor,
    BoxConstraints? constraints,
    BoxConstraints? viewConstraints,
    bool? isFullScreen,
    CustomSearchController searchController,
    TextCapitalization textCapitalization,
    required CustomSearchSuggestionsBuilder suggestionsBuilder,
    TextInputAction? textInputAction,
    String? labelText,
    TextInputType? keyboardType,
  }) = _CustomSearchAnchorWithSearchBar;

  final String? labelText;

  final bool? isFullScreen;

  final CustomSearchController? searchController;

  final CustomSearchViewBuilder? viewBuilder;

  final Widget? viewLeading;

  final Iterable<Widget>? viewTrailing;

  final String? viewHintText;

  final Color? viewBackgroundColor;

  final double? viewElevation;

  final Color? viewSurfaceTintColor;

  final BorderSide? viewSide;

  final RoundedRectangleBorder? viewShape;

  final Widget? dividerWidget;

  final TextStyle? headerTextStyle;

  final TextStyle? headerHintStyle;

  final Color? dividerColor;

  final BoxConstraints? viewConstraints;

  final TextCapitalization? textCapitalization;

  final ValueChanged<String>? viewOnChanged;

  final ValueChanged<String>? viewOnSubmitted;

  final CustomSearchAnchorChildBuilder builder;

  final CustomSearchSuggestionsBuilder suggestionsBuilder;

  final TextInputAction? textInputAction;

  final TextInputType? keyboardType;

  @override
  State<CustomSearchAnchor> createState() => _CustomSearchAnchorState();
}

class _CustomSearchAnchorState extends State<CustomSearchAnchor> {
  Size? _screenSize;
  bool _anchorIsVisible = true;
  final GlobalKey _anchorKey = GlobalKey();
  bool get _viewIsOpen => !_anchorIsVisible;
  CustomSearchController? _internalSearchController;
  CustomSearchController get _searchController =>
      widget.searchController ??
      (_internalSearchController ??= CustomSearchController());

  @override
  void initState() {
    super.initState();
    _searchController._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Size updatedScreenSize = MediaQuery.of(context).size;
    if (_screenSize != null && _screenSize != updatedScreenSize) {
      if (_searchController.isOpen && !getShowFullScreenView()) {
        _closeView(null);
      }
    }
    _screenSize = updatedScreenSize;
  }

  @override
  void didUpdateWidget(CustomSearchAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController?._detach(this);
      _searchController._attach(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.searchController?._detach(this);
    _internalSearchController?._detach(this);
    _internalSearchController?.dispose();
  }

  void _openView() {
    final NavigatorState navigator = Navigator.of(context);
    navigator.push(_SearchViewRoute(
      viewOnChanged: widget.viewOnChanged,
      viewOnSubmitted: widget.viewOnSubmitted,
      dividerWidget: widget.dividerWidget,
      viewLeading: widget.viewLeading,
      viewTrailing: widget.viewTrailing,
      viewHintText: widget.viewHintText,
      viewBackgroundColor: widget.viewBackgroundColor,
      viewElevation: widget.viewElevation,
      viewSurfaceTintColor: widget.viewSurfaceTintColor,
      viewSide: widget.viewSide,
      viewShape: widget.viewShape,
      viewHeaderTextStyle: widget.headerTextStyle,
      viewHeaderHintStyle: widget.headerHintStyle,
      dividerColor: widget.dividerColor,
      viewConstraints: widget.viewConstraints,
      showFullScreenView: getShowFullScreenView(),
      toggleVisibility: toggleVisibility,
      textDirection: Directionality.of(context),
      viewBuilder: widget.viewBuilder,
      anchorKey: _anchorKey,
      searchController: _searchController,
      suggestionsBuilder: widget.suggestionsBuilder,
      textCapitalization: widget.textCapitalization,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
    ));
  }

  void _closeView(String? selectedText) {
    if (selectedText != null) {
      _searchController.text = selectedText;
    }
    Navigator.of(context).pop();
  }

  bool toggleVisibility() {
    setState(() {
      _anchorIsVisible = !_anchorIsVisible;
    });
    return _anchorIsVisible;
  }

  bool getShowFullScreenView() {
    if (widget.isFullScreen != null) {
      return widget.isFullScreen!;
    }

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: _anchorKey,
      opacity: _anchorIsVisible ? 1.0 : 0.0,
      duration: _kAnchorFadeDuration,
      child: GestureDetector(
        onTap: _openView,
        child: widget.builder(context, _searchController),
      ),
    );
  }
}

class _SearchViewRoute extends PopupRoute<_SearchViewRoute> {
  _SearchViewRoute({
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.toggleVisibility,
    this.textDirection,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.dividerWidget,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    required this.showFullScreenView,
    required this.anchorKey,
    required this.searchController,
    required this.suggestionsBuilder,
    required this.capturedThemes,
    this.textInputAction,
    this.keyboardType,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final ValueGetter<bool>? toggleVisibility;
  final TextDirection? textDirection;
  final CustomSearchViewBuilder? viewBuilder;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final BoxConstraints? viewConstraints;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final Widget? dividerWidget;
  final GlobalKey anchorKey;
  final CustomSearchController searchController;
  final CustomSearchSuggestionsBuilder suggestionsBuilder;
  final CapturedThemes capturedThemes;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  late final SearchViewThemeData viewDefaults;
  late final SearchViewThemeData viewTheme;
  final RectTween _rectTween = RectTween();

  Rect? getRect() {
    final BuildContext? context = anchorKey.currentContext;
    if (context != null) {
      final RenderBox searchBarBox = context.findRenderObject()! as RenderBox;
      final Size boxSize = searchBarBox.size;
      final NavigatorState navigator = Navigator.of(context);
      final Offset boxLocation = searchBarBox.localToGlobal(Offset.zero,
          ancestor: navigator.context.findRenderObject());
      return boxLocation & boxSize;
    }
    return null;
  }

  @override
  TickerFuture didPush() {
    assert(anchorKey.currentContext != null);
    updateViewConfig(anchorKey.currentContext!);
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    return super.didPush();
  }

  @override
  bool didPop(_SearchViewRoute? result) {
    assert(anchorKey.currentContext != null);
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    return super.didPop(result);
  }

  void updateViewConfig(BuildContext context) {
    viewDefaults =
        _SearchViewDefaultsM3(context, isFullScreen: showFullScreenView);
    viewTheme = SearchViewTheme.of(context);
  }

  void updateTweens(BuildContext context) {
    final RenderBox navigator =
        Navigator.of(context).context.findRenderObject()! as RenderBox;
    final Size screenSize = navigator.size;
    final Rect anchorRect = getRect() ?? Rect.zero;

    final BoxConstraints effectiveConstraints =
        viewConstraints ?? viewTheme.constraints ?? viewDefaults.constraints!;
    _rectTween.begin = anchorRect;

    final double viewWidth = clampDouble(anchorRect.width,
        effectiveConstraints.minWidth, effectiveConstraints.maxWidth);
    final double viewHeight = clampDouble(screenSize.height * 2 / 3,
        effectiveConstraints.minHeight, effectiveConstraints.maxHeight);

    switch (textDirection ?? TextDirection.ltr) {
      case TextDirection.ltr:
        final double viewLeftToScreenRight = screenSize.width - anchorRect.left;
        final double viewTopToScreenBottom = screenSize.height - anchorRect.top;

        Offset topLeft = anchorRect.topLeft;
        if (viewLeftToScreenRight < viewWidth) {
          topLeft = Offset(
              screenSize.width - math.min(viewWidth, screenSize.width),
              topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          topLeft = Offset(topLeft.dx,
              screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final Size endSize = Size(viewWidth, viewHeight);
        _rectTween.end =
            showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
        return;
      case TextDirection.rtl:
        final double viewRightToScreenLeft = anchorRect.right;
        final double viewTopToScreenBottom = screenSize.height - anchorRect.top;

        Offset topLeft =
            Offset(math.max(anchorRect.right - viewWidth, 0.0), anchorRect.top);
        if (viewRightToScreenLeft < viewWidth) {
          topLeft = Offset(0.0, topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          topLeft = Offset(topLeft.dx,
              screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final Size endSize = Size(viewWidth, viewHeight);
        _rectTween.end =
            showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
    }
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Directionality(
      textDirection: textDirection ?? TextDirection.ltr,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubicEmphasized,
            reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
          );

          final Rect viewRect = _rectTween.evaluate(curvedAnimation)!;
          final double topPadding = showFullScreenView
              ? lerpDouble(0.0, MediaQuery.paddingOf(context).top,
                  curvedAnimation.value)!
              : 0.0;

          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: _kViewFadeOnInterval,
              reverseCurve: _kViewFadeOnInterval.flipped,
            ),
            child: capturedThemes.wrap(
              _ViewContent(
                dividerWidget: dividerWidget,
                viewOnChanged: viewOnChanged,
                viewOnSubmitted: viewOnSubmitted,
                viewLeading: viewLeading,
                viewTrailing: viewTrailing,
                viewHintText: viewHintText,
                viewBackgroundColor: viewBackgroundColor,
                viewElevation: viewElevation,
                viewSurfaceTintColor: viewSurfaceTintColor,
                viewSide: viewSide,
                viewShape: viewShape,
                viewHeaderTextStyle: viewHeaderTextStyle,
                viewHeaderHintStyle: viewHeaderHintStyle,
                dividerColor: dividerColor,
                showFullScreenView: showFullScreenView,
                animation: curvedAnimation,
                topPadding: topPadding,
                viewMaxWidth: _rectTween.end!.width,
                viewRect: viewRect,
                viewBuilder: viewBuilder,
                searchController: searchController,
                suggestionsBuilder: suggestionsBuilder,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Duration get transitionDuration => _kOpenViewDuration;
}

class _ViewContent extends StatefulWidget {
  const _ViewContent({
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.textCapitalization,
    this.dividerWidget,
    required this.showFullScreenView,
    required this.topPadding,
    required this.animation,
    required this.viewMaxWidth,
    required this.viewRect,
    required this.searchController,
    required this.suggestionsBuilder,
    this.textInputAction,
    this.keyboardType,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final CustomSearchViewBuilder? viewBuilder;

  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final Widget? dividerWidget;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final double topPadding;
  final Animation<double> animation;
  final double viewMaxWidth;
  final Rect viewRect;
  final CustomSearchController searchController;
  final CustomSearchSuggestionsBuilder suggestionsBuilder;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  State<_ViewContent> createState() => _ViewContentState();
}

class _ViewContentState extends State<_ViewContent> {
  Size? _screenSize;
  late Rect _viewRect;
  late final CustomSearchController _controller;
  Widget result = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _viewRect = widget.viewRect;
    _controller = widget.searchController;
    _controller.addListener(updateSuggestions);
  }

  @override
  void didUpdateWidget(covariant _ViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewRect != oldWidget.viewRect) {
      setState(() => _viewRect = widget.viewRect);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Size updatedScreenSize = MediaQuery.of(context).size;

    if (_screenSize != updatedScreenSize) {
      _screenSize = updatedScreenSize;
      if (widget.showFullScreenView) {
        _viewRect = Offset.zero & _screenSize!;
      }
    }
    unawaited(updateSuggestions());
  }

  @override
  void dispose() {
    _controller.removeListener(updateSuggestions);
    super.dispose();
  }

  Widget viewBuilder(Widget suggestion) {
    if (widget.viewBuilder == null) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: suggestion,
      );
    }
    return widget.viewBuilder!(suggestion);
  }

  Future<void> updateSuggestions() async {
    final Widget suggestion =
        await widget.suggestionsBuilder(context, _controller);

    setStateIfMounted(() => result = suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final Widget defaultLeading = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );

    final List<Widget> defaultTrailing = <Widget>[
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          final text = _controller.text;
          if (text.isEmpty) {
            _controller.closeView('');
          } else {
            _controller.clear();
          }
        },
      ),
    ];

    final SearchViewThemeData viewDefaults =
        _SearchViewDefaultsM3(context, isFullScreen: widget.showFullScreenView);
    final SearchViewThemeData viewTheme = SearchViewTheme.of(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);

    final Color effectiveBackgroundColor = widget.viewBackgroundColor ??
        viewTheme.backgroundColor ??
        viewDefaults.backgroundColor!;
    final Color effectiveSurfaceTint = widget.viewSurfaceTintColor ??
        viewTheme.surfaceTintColor ??
        viewDefaults.surfaceTintColor!;
    final double effectiveElevation =
        widget.viewElevation ?? viewTheme.elevation ?? viewDefaults.elevation!;
    final BorderSide? effectiveSide =
        widget.viewSide ?? viewTheme.side ?? viewDefaults.side;
    OutlinedBorder effectiveShape =
        widget.viewShape ?? viewTheme.shape ?? viewDefaults.shape!;
    if (effectiveSide != null) {
      effectiveShape = effectiveShape.copyWith(side: effectiveSide);
    }
    final Color effectiveDividerColor = widget.dividerColor ??
        viewTheme.dividerColor ??
        dividerTheme.color ??
        viewDefaults.dividerColor!;
    final TextStyle? effectiveTextStyle = widget.viewHeaderTextStyle ??
        viewTheme.headerTextStyle ??
        viewDefaults.headerTextStyle;
    final TextStyle? effectiveHintStyle = widget.viewHeaderHintStyle ??
        viewTheme.headerHintStyle ??
        widget.viewHeaderTextStyle ??
        viewTheme.headerTextStyle ??
        viewDefaults.headerHintStyle;

    final Widget viewDivider = DividerTheme(
      data: dividerTheme.copyWith(color: effectiveDividerColor),
      child: widget.dividerWidget ?? const Divider(height: 1),
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: _viewRect.topLeft,
        child: SizedBox(
          width: _viewRect.width,
          height: _viewRect.height,
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: effectiveShape,
            color: effectiveBackgroundColor,
            surfaceTintColor: effectiveSurfaceTint,
            elevation: effectiveElevation,
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: math.min(widget.viewMaxWidth, _screenSize!.width),
                minWidth: 0,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: widget.animation,
                    curve: _kViewIconsFadeOnInterval,
                    reverseCurve: _kViewIconsFadeOnInterval.flipped,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: widget.topPadding),
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: SizedBox(
                            height: 55,
                            child: CustomSearchBar(
                              autoFocus: true,
                              constraints: widget.showFullScreenView
                                  ? BoxConstraints(
                                      minHeight: _SearchViewDefaultsM3
                                          .fullScreenBarHeight)
                                  : null,
                              leading: widget.viewLeading ?? defaultLeading,
                              trailing: widget.viewTrailing ?? defaultTrailing,
                              hintText: widget.viewHintText,
                              fillColor: Colors.transparent,
                              backgroundColor:
                                  const WidgetStatePropertyAll<Color>(
                                Colors.transparent,
                              ),
                              overlayColor: const WidgetStatePropertyAll<Color>(
                                Colors.transparent,
                              ),
                              elevation:
                                  const WidgetStatePropertyAll<double>(0.0),
                              textStyle: WidgetStatePropertyAll<TextStyle?>(
                                  effectiveTextStyle),
                              hintStyle: WidgetStatePropertyAll<TextStyle?>(
                                  effectiveHintStyle),
                              controller: _controller,
                              onChanged: (String value) {
                                if (value.isEmpty && _controller.isOpen) {
                                  _controller.closeView(value);
                                }

                                widget.viewOnChanged?.call(value);
                                updateSuggestions();
                              },
                              onSubmitted: widget.viewOnSubmitted,
                              textCapitalization: widget.textCapitalization,
                              textInputAction: widget.textInputAction,
                              keyboardType: widget.keyboardType,
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: widget.animation,
                          curve: _kViewDividerFadeOnInterval,
                          reverseCurve: _kViewFadeOnInterval.flipped,
                        ),
                        child: viewDivider,
                      ),
                      Expanded(
                        child: DividerTheme(
                          data: dividerTheme.copyWith(
                            color: effectiveDividerColor,
                          ),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: widget.animation,
                              curve: _kViewListFadeOnInterval,
                              reverseCurve: _kViewListFadeOnInterval.flipped,
                            ),
                            child: viewBuilder(result),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomSearchAnchorWithSearchBar extends CustomSearchAnchor {
  _CustomSearchAnchorWithSearchBar({
    Widget? barLeading,
    Iterable<Widget>? barTrailing,
    String? barHintText,
    super.dividerWidget,
    GestureTapCallback? onTap,
    WidgetStateProperty<double?>? barElevation,
    WidgetStateProperty<Color?>? barBackgroundColor,
    WidgetStateProperty<Color?>? barOverlayColor,
    WidgetStateProperty<BorderSide?>? barSide,
    WidgetStateProperty<RoundedRectangleBorder?>? barShape,
    WidgetStateProperty<EdgeInsetsGeometry?>? barPadding,
    WidgetStateProperty<TextStyle?>? barTextStyle,
    WidgetStateProperty<TextStyle?>? barHintStyle,
    super.viewLeading,
    super.viewTrailing,
    String? viewHintText,
    super.viewBackgroundColor,
    super.viewElevation,
    super.viewSide,
    super.viewShape,
    TextStyle? viewHeaderTextStyle,
    TextStyle? viewHeaderHintStyle,
    super.dividerColor,
    BoxConstraints? constraints,
    super.viewConstraints,
    super.isFullScreen,
    super.searchController,
    super.textCapitalization,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    required super.suggestionsBuilder,
    super.textInputAction,
    super.labelText,
    super.keyboardType,
  }) : super._(
            viewHintText: viewHintText ?? barHintText,
            headerTextStyle: viewHeaderTextStyle,
            headerHintStyle: viewHeaderHintStyle,
            viewOnSubmitted: onSubmitted,

            // viewOnChanged: onChanged,
            builder: (BuildContext context, CustomSearchController controller) {
              return CustomSearchBar(
                constraints: constraints,
                controller: controller,
                // onTap: () {
                //   // controller.openView();
                //   onTap?.call();
                // },
                onTap: onTap,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                hintText: barHintText,
                hintStyle: barHintStyle,
                textStyle: barTextStyle,
                elevation: barElevation,
                backgroundColor: barBackgroundColor,
                overlayColor: barOverlayColor,
                side: barSide,
                labelText: labelText,
                shape: barShape,
                padding: barPadding,
                leading: barLeading,
                trailing: barTrailing,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
              );
            });
}

class CustomSearchController extends TextEditingController {
  _CustomSearchAnchorState? _anchor;

  bool get isAttached => _anchor != null;

  bool get isOpen {
    assert(isAttached);
    return _anchor!._viewIsOpen;
  }

  void openView() {
    assert(isAttached);
    _anchor?._openView();
  }

  void closeView(String? selectedText) {
    assert(isAttached);
    _anchor?._closeView(selectedText);
  }

  void _attach(_CustomSearchAnchorState anchor) {
    _anchor = anchor;
  }

  void _detach(_CustomSearchAnchorState anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    this.fillColor,
    this.controller,
    this.focusNode,
    this.hintText,
    this.leading,
    this.trailing,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.constraints,
    this.elevation,
    this.backgroundColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.overlayColor,
    this.side,
    this.shape,
    this.padding,
    this.textStyle,
    this.hintStyle,
    this.textCapitalization,
    this.autoFocus = false,
    this.textInputAction,
    this.keyboardType,
    this.labelText,
  });

  final String? labelText;

  final CustomSearchController? controller;

  final Color? fillColor;

  final FocusNode? focusNode;

  final String? hintText;

  final Widget? leading;

  final Iterable<Widget>? trailing;

  final GestureTapCallback? onTap;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final BoxConstraints? constraints;

  final WidgetStateProperty<double?>? elevation;

  final WidgetStateProperty<Color?>? backgroundColor;

  final WidgetStateProperty<Color?>? shadowColor;

  final WidgetStateProperty<Color?>? surfaceTintColor;

  final WidgetStateProperty<Color?>? overlayColor;

  final WidgetStateProperty<BorderSide?>? side;

  final WidgetStateProperty<RoundedRectangleBorder?>? shape;

  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  final WidgetStateProperty<TextStyle?>? textStyle;

  final WidgetStateProperty<TextStyle?>? hintStyle;

  final TextCapitalization? textCapitalization;

  final bool autoFocus;

  final TextInputAction? textInputAction;

  final TextInputType? keyboardType;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final WidgetStatesController _internalStatesController;
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _internalStatesController = WidgetStatesController();
    _internalStatesController.addListener(_listener);
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    _internalStatesController
      ..removeListener(_listener)
      ..dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final IconThemeData iconTheme = IconTheme.of(context);
    final SearchBarThemeData searchBarTheme = SearchBarTheme.of(context);
    final SearchBarThemeData defaults = _SearchBarDefaultsM3(context);

    T? resolve<T>(
      WidgetStateProperty<T>? widgetValue,
      WidgetStateProperty<T>? themeValue,
      WidgetStateProperty<T>? defaultValue,
    ) {
      final Set<WidgetState> states = _internalStatesController.value;
      return widgetValue?.resolve(states) ??
          themeValue?.resolve(states) ??
          defaultValue?.resolve(states);
    }

    final TextStyle? effectiveTextStyle = resolve<TextStyle?>(
        widget.textStyle, searchBarTheme.textStyle, defaults.textStyle);
    final double? effectiveElevation = resolve<double?>(
        widget.elevation, searchBarTheme.elevation, defaults.elevation);
    final Color? effectiveShadowColor = resolve<Color?>(
        widget.shadowColor, searchBarTheme.shadowColor, defaults.shadowColor);
    final Color? effectiveBackgroundColor = resolve<Color?>(
        widget.backgroundColor,
        searchBarTheme.backgroundColor,
        defaults.backgroundColor);
    final Color? effectiveSurfaceTintColor = resolve<Color?>(
        widget.surfaceTintColor,
        searchBarTheme.surfaceTintColor,
        defaults.surfaceTintColor);
    final RoundedRectangleBorder? effectiveShape =
        resolve<RoundedRectangleBorder?>(
      widget.shape,
      const WidgetStatePropertyAll(RoundedRectangleBorder()),
      const WidgetStatePropertyAll(RoundedRectangleBorder()),
    );
    final BorderSide? effectiveSide =
        resolve<BorderSide?>(widget.side, searchBarTheme.side, defaults.side);
    // final EdgeInsetsGeometry? effectivePadding = resolve<EdgeInsetsGeometry?>(
    //     widget.padding, searchBarTheme.padding, defaults.padding);
    final WidgetStateProperty<Color?>? effectiveOverlayColor =
        widget.overlayColor ??
            searchBarTheme.overlayColor ??
            defaults.overlayColor;
    final TextCapitalization effectiveTextCapitalization =
        widget.textCapitalization ??
            searchBarTheme.textCapitalization ??
            defaults.textCapitalization!;

    final Set<WidgetState> states = _internalStatesController.value;
    final TextStyle? effectiveHintStyle = widget.hintStyle?.resolve(states) ??
        searchBarTheme.hintStyle?.resolve(states) ??
        widget.textStyle?.resolve(states) ??
        searchBarTheme.textStyle?.resolve(states) ??
        defaults.hintStyle?.resolve(states);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isIconThemeColorDefault(Color? color) {
      if (isDark) {
        return color == kDefaultIconLightColor;
      }
      return color == kDefaultIconDarkColor;
    }

    Widget? leading;
    if (widget.leading != null) {
      leading = IconTheme.merge(
        data: isIconThemeColorDefault(iconTheme.color)
            ? IconThemeData(color: colorScheme.onSurface)
            : iconTheme,
        child: widget.leading!,
      );
    }

    List<Widget>? trailing;
    if (widget.trailing != null) {
      trailing = widget.trailing
          ?.map((Widget trailing) => IconTheme.merge(
                data: isIconThemeColorDefault(iconTheme.color)
                    ? IconThemeData(color: colorScheme.onSurfaceVariant)
                    : iconTheme,
                child: trailing,
              ))
          .toList();
    }

    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    void onSubmitted(String value) {
      widget.onSubmitted?.call(value);
      if (_focusNode.hasFocus) {
        _internalStatesController.update(WidgetState.focused, false);
      }
    }

    bool isScrolledUnder = settings?.isScrolledUnder ?? false;

    return ConstrainedBox(
      constraints: widget.constraints ??
          searchBarTheme.constraints ??
          defaults.constraints!,
      child: AnimatedOpacity(
        opacity: !isScrolledUnder ? 1 : 0,
        // opacity: 1,
        duration: const Duration(milliseconds: 250),
        curve: const Cubic(0.2, 0.0, 0.0, 1.0),
        child: Material(
          elevation: effectiveElevation!,
          shadowColor: effectiveShadowColor,
          surfaceTintColor: effectiveSurfaceTintColor,
          color: effectiveBackgroundColor,
          shape: effectiveShape?.copyWith(side: effectiveSide),
          child: InkWell(
            onTap: () {
              widget.onTap?.call();
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
            },
            overlayColor: effectiveOverlayColor,
            customBorder: effectiveShape?.copyWith(side: effectiveSide),
            statesController: _internalStatesController,
            child: TextField(
              textDirection: textDirection,
              onTap: widget.onTap,
              autofocus: widget.autoFocus,
              onTapAlwaysCalled: true,
              enableInteractiveSelection: true,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: onSubmitted,
              controller: widget.controller,
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.editable(
                  onLookUp: null,
                  onSearchWeb: null,
                  onShare: null,
                  onLiveTextInput: null,
                  anchors: editableTextState.contextMenuAnchors,
                  clipboardStatus: ClipboardStatus.notPasteable,
                  onCopy: editableTextState.currentTextEditingValue.text
                          .trim()
                          .isNotEmpty
                      ? () => editableTextState
                          .copySelection(SelectionChangedCause.toolbar)
                      : null,
                  onCut: null,
                  onPaste: () {
                    editableTextState.pasteText(SelectionChangedCause.tap);
                  },
                  onSelectAll: editableTextState.currentTextEditingValue.text
                          .trim()
                          .isNotEmpty
                      ? () => editableTextState
                          .selectAll(SelectionChangedCause.toolbar)
                      : null,
                );
              },
              style: effectiveTextStyle,
              decoration: InputDecoration(
                hintStyle: effectiveHintStyle,
                enabledBorder: OutlineInputBorder(
                  borderRadius: effectiveShape
                      ?.copyWith(side: effectiveSide)
                      .borderRadius as BorderRadius,
                  borderSide: effectiveSide ??
                      const BorderSide(color: Colors.transparent),
                ),
                border: OutlineInputBorder(
                  borderRadius: effectiveShape
                      ?.copyWith(side: effectiveSide)
                      .borderRadius as BorderRadius,
                  borderSide: effectiveSide ??
                      const BorderSide(color: Colors.transparent),
                ),
                filled: true,
                fillColor: Colors.transparent,
                labelText: widget.labelText,
                prefixIcon: leading,
                suffixIcon: trailing != null ? Row(children: trailing) : null,
                suffixIconColor: colorScheme.primary,
                suffixIconConstraints: const BoxConstraints(maxWidth: 50),
                contentPadding: const EdgeInsets.only(left: 15.0, right: 15.0),
                errorBorder: OutlineInputBorder(
                  borderRadius: effectiveShape
                      ?.copyWith(side: effectiveSide)
                      .borderRadius as BorderRadius,
                ),
                focusColor: colorScheme.surface.withOpacity(0.5),
                focusedBorder: OutlineInputBorder(
                  borderRadius: effectiveShape
                      ?.copyWith(side: effectiveSide)
                      .borderRadius as BorderRadius,
                  borderSide: effectiveSide ??
                      const BorderSide(color: Colors.transparent),
                ),
              ),
              textCapitalization: effectiveTextCapitalization,
              textInputAction: widget.textInputAction,
              keyboardType: widget.keyboardType,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBarDefaultsM3 extends SearchBarThemeData {
  _SearchBarDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateColor.resolveWith(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return _colors.onSurface.withOpacity(0.04);
          }
          return _colors.surfaceContainerHighest.withOpacity(0.16);
        },
      );
  // WidgetStatePropertyAll<Color>(_colors.surface);

  @override
  WidgetStateProperty<double>? get elevation =>
      const WidgetStatePropertyAll<double>(6.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      WidgetStatePropertyAll<Color>(_colors.shadow);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      WidgetStatePropertyAll<Color>(_colors.surfaceTint);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSurface.withOpacity(0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSurface.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      });

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 8.0));

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      WidgetStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurface));

  @override
  WidgetStateProperty<TextStyle?> get hintStyle =>
      WidgetStatePropertyAll<TextStyle?>(
          _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant));

  @override
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360.0, maxWidth: 800.0, minHeight: 56.0);

  @override
  TextCapitalization get textCapitalization => TextCapitalization.none;
}

class _SearchViewDefaultsM3 extends SearchViewThemeData {
  _SearchViewDefaultsM3(this.context, {required this.isFullScreen});

  final BuildContext context;
  final bool isFullScreen;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  static double fullScreenBarHeight = 72.0;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  double? get elevation => 6.0;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  OutlinedBorder? get shape => isFullScreen
      ? const RoundedRectangleBorder()
      : const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28.0)));

  @override
  TextStyle? get headerTextStyle =>
      _textTheme.bodyLarge?.copyWith(color: _colors.onSurface);

  @override
  TextStyle? get headerHintStyle =>
      _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant);

  @override
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360.0, minHeight: 240.0);

  @override
  Color? get dividerColor => _colors.outline;
}
