part of '../view/reading.dart';

mixin _ReadingVars on State<ReadingView> {
  // vars
  Timer? _setEnabledSystemUIMode;
  Book? _book;
  Chapter? _chapter;
  bool _isLoading = true;
  bool _enabledSystemUIMode = false;
  bool _showFooterWidget = true;
  // ignore: unused_field
  List<Chapter> _chapters = [];
  List<ChapterContent> _data = [];

  late final BookRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<BookRepository>();
  }
}

mixin _ReadingScroll on State<ReadingView>, _ReadingVars {
  late final ReaderController _readerController;

  @override
  void initState() {
    _readerController = ReaderController();
    super.initState();
  }

  @override
  void dispose() {
    _readerController.dispose();
    super.dispose();
  }

  void _onStartScroll(ScrollStartNotification scrollNotification) {
    _setEnabledSystemUIMode?.cancel();
    _setEnabledSystemUIMode = Timer(const Duration(milliseconds: 400), () {
      if (!_enabledSystemUIMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        _enabledSystemUIMode = true;
      }
    });
  }

  void _onEndScroll(ScrollEndNotification scrollNotification) {
    _setEnabledSystemUIMode?.cancel();
    _setEnabledSystemUIMode = Timer(const Duration(milliseconds: 600), () {
      if (_enabledSystemUIMode) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _enabledSystemUIMode = false;
      }
    });
  }

  bool _onNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollStartNotification) {
      _onStartScroll(scrollNotification);
    } else if (scrollNotification is ScrollUpdateNotification) {
      _onUpdateScroll(scrollNotification);
      _onUpdateScrollDelta(scrollNotification);
    } else if (scrollNotification is ScrollEndNotification) {
      _onEndScroll(scrollNotification);
    }
    return scrollNotification.depth == 0;
  }

  void _onUpdateScroll(ScrollUpdateNotification scrollNotification) {}

  void _onUpdateScrollDelta(ScrollUpdateNotification scrollNotification) {}
}
