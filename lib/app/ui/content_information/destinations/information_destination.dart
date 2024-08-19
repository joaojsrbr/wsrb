import 'package:app_wsrb_jsr/app/ui/content_information/widgets/scope.dart';
import 'package:app_wsrb_jsr/app/utils/copy_to_clipboard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InformationDestination extends StatefulWidget {
  const InformationDestination({super.key});

  @override
  State<InformationDestination> createState() => _InformationDestinationState();
}

class _InformationDestinationState extends State<InformationDestination>
    with AutomaticKeepAliveClientMixin {
  String _substring = "";
  bool _isOver100 = false;
  bool _isSelection = false;
  bool _expanded = false;
  final Map<String, Widget> _contentInformation = {};
  final FocusNode _focusNode = FocusNode();
  late Content _content;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    _content = ContentScope.contentOf(context);

    if (!_expanded) _isOver100 = (_content.sinopse ?? "").length > 100;

    if (_isOver100 && !_expanded) {
      _substring = "${_content.sinopse?.substring(0, 100)} ...";
    }

    if (_content.anilistMedia != null && mounted) {
      _getInformation();
    }

    super.didChangeDependencies();
  }

  void _getInformation() {
    _contentInformation.clear();
    final Locale appLocale = Localizations.localeOf(context);
    final ThemeData themeData = Theme.of(context);

    Map<String, Widget> cache = {};
    final now = DateTime.now();

    if (_content.anilistMedia?.startDate?.isEmpty != true) {
      _contentInformation["Data de início"] = Text(
        key: ValueKey(DateTime(
          _content.anilistMedia!.startDate!.year!,
          _content.anilistMedia!.startDate!.month!,
          _content.anilistMedia!.startDate!.day!,
        ).toString()),
        DateFormat("d MMMM y", appLocale.toLanguageTag()).format(
          DateTime(
            _content.anilistMedia!.startDate!.year!,
            _content.anilistMedia!.startDate!.month!,
            _content.anilistMedia!.startDate!.day!,
          ),
        ),
      );
    }
    if (_content.anilistMedia?.endDate?.isEmpty != true) {
      cache["Data final"] = Text(
        key: ValueKey(DateTime(
          _content.anilistMedia!.endDate!.year!,
          _content.anilistMedia!.endDate!.month!,
          _content.anilistMedia!.endDate!.day!,
        ).toString()),
        DateFormat("d MMMM y", appLocale.toLanguageTag()).format(
          DateTime(
            _content.anilistMedia!.endDate!.year!,
            _content.anilistMedia!.endDate!.month!,
            _content.anilistMedia!.endDate!.day!,
          ),
        ),
      );
    }
    if (_content.anilistMedia?.averageScore != null) {
      cache["Pontuação"] = Text.rich(
        key: ValueKey((_content.anilistMedia!.averageScore! / 10).toString()),
        TextSpan(
          children: [
            TextSpan(
              text: (_content.anilistMedia!.averageScore! / 10).toString(),
            ),
            const TextSpan(
              text: " / ",
              style: TextStyle(color: Colors.white),
            ),
            const TextSpan(text: "10", style: TextStyle(color: Colors.white)),
          ],
          style: TextStyle(color: themeData.colorScheme.primary),
        ),
      );
    }
    if (_content.anilistMedia?.episodes != null) {
      cache["Total de episódios"] = Text(
        key: ValueKey(_content.anilistMedia!.episodes.toString()),
        _content.anilistMedia!.episodes.toString(),
      );
    }
    if (_content.anilistMedia?.format != null) {
      cache["Formato"] = Text(
        key: ValueKey(_content.anilistMedia!.format!.name),
        _content.anilistMedia!.format!.name,
      );
    }
    if (_content.anilistMedia?.status != null) {
      cache["Status"] = Text(
        key: ValueKey(_content.anilistMedia!.status!.toString()),
        _content.anilistMedia!.status!.toString(),
      );
    }
    if (_content.anilistMedia?.popularity != null) {
      cache["Popularidade"] = Text(
        key: ValueKey(_content.anilistMedia!.popularity!.toString()),
        _content.anilistMedia!.popularity!.toString(),
      );
    }
    if (_content.anilistMedia?.favourites != null) {
      cache["Favoritos"] = Text(
        key: ValueKey(_content.anilistMedia!.favourites!.toString()),
        _content.anilistMedia!.favourites!.toString(),
      );
    }
    if (_content.anilistMedia?.season != null) {
      cache["Temporada"] = Text(
        key: ValueKey("${_content.anilistMedia!.season!.name} ${now.year}"),
        "${_content.anilistMedia!.season!.name} ${now.year}",
      );
    }
    if (_content.anilistMedia?.title?.romaji != null) {
      cache["Nome Romaji"] = GestureDetector(
        onLongPress: () async {
          copyToClipboard(
            context,
            messageCopy: _content.anilistMedia!.title!.romaji!,
            messageSnackBar: 'Copiado para a área de transferência!',
          );
          await Feedback.forLongPress(context);
        },
        child: Text(
          key: ValueKey(_content.anilistMedia!.title!.romaji!),
          _content.anilistMedia!.title!.romaji!,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          maxLines: 1,
        ),
      );
    }

    if (!mapEquals(cache, _contentInformation)) {
      _contentInformation.clear();
      _contentInformation.addEntries(cache.entries);
    }
  }

  void _setExpanded() {
    if (!_isOver100 || _isSelection) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData themeData = Theme.of(context);

    return ListView(
      // shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        if ((_content.sinopse ?? "").isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Card.filled(
              color: themeData.colorScheme.primary.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                overlayColor: _OverlayColor(context),
                borderRadius: BorderRadius.circular(8),
                onLongPress: () {
                  _focusNode.requestFocus();
                },
                onTap: _setExpanded,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sinopse',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 28),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: double.infinity,
                            child: SelectableText(
                              !_expanded
                                  ? _substring
                                  : (_content.sinopse ?? ""),
                              focusNode: _focusNode,
                              onSelectionChanged: (selection, cause) {
                                addPostFrameSetState(() {
                                  if (cause ==
                                      SelectionChangedCause.longPress) {
                                    _isSelection = true;
                                  } else if (cause ==
                                      SelectionChangedCause.tap) {
                                    _isSelection = false;
                                  }
                                });
                                customLog(cause);
                              },
                              enableInteractiveSelection: true,
                              onTap: _setExpanded,
                              textAlign: TextAlign.justify,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_contentInformation.isNotEmpty)
          Padding(
            key: ValueKey(_contentInformation.values.length),
            padding: EdgeInsets.only(
                right: 8,
                left: 8,
                bottom: 12,
                top: (_content.sinopse ?? "").isEmpty ? 8 : 0),
            child: Card.filled(
              color: themeData.colorScheme.primary.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children:
                    _contentInformation.entries.mapIndexed((index, entry) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                      top: index == 0 ? 8 : 0,
                      right: 8,
                      left: 8,
                    ),
                    child: DefaultTextStyle(
                      style: themeData.textTheme.labelLarge!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Flexible(child: entry.value),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_content.anilistMedia?.genres != null || _content.genres.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  'Categorias',
                  style: themeData.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                  left: 12,
                  bottom: 12,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_content.genres.isNotEmpty
                          ? _content.genres.map((e) => e.label)
                          : _content.anilistMedia?.genres ?? <String>[])
                      .map((e) => e.capitalize)
                      .map(
                        (e) => Card.filled(
                          color:
                              themeData.colorScheme.primary.withOpacity(0.04),
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              e,
                              style: themeData.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        if (_content.anilistMedia?.characters?.nodes != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  'Personagens',
                  style: themeData.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Builder(builder: (context) {
                  final list = _content.anilistMedia?.characters?.nodes
                      ?.unique((staff) => staff.name!.full!);
                  if (list == null) return const SizedBox.shrink();
                  return ListView.builder(
                    itemCount: list.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final personagem = list.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onLongPress: () async {
                            copyToClipboard(
                              context,
                              messageCopy: personagem.name!.full!.trim(),
                              messageSnackBar:
                                  'Copiado para a área de transferência!',
                            );
                            await Feedback.forLongPress(context);
                          },
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    height: 140,
                                    maxHeightDiskCache: 400,
                                    maxWidthDiskCache: 200,
                                    width: 120,
                                    imageUrl: personagem.image!.large!,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Flexible(
                                  child: Text(
                                    personagem.name!.full!,
                                    style: themeData.textTheme.titleSmall,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (_content.anilistMedia?.staff?.nodes != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  'Staff',
                  style: themeData.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Builder(builder: (context) {
                  final list = _content.anilistMedia?.staff?.nodes
                      ?.unique((staff) => staff.name!.full!);
                  if (list == null) return const SizedBox.shrink();
                  return ListView.builder(
                    itemCount: list.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final staff = list.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onLongPress: () async {
                            copyToClipboard(
                              context,
                              messageCopy: staff.name!.full!.trim(),
                              messageSnackBar:
                                  'Copiado para a área de transferência!',
                            );
                            await Feedback.forLongPress(context);
                          },
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    height: 140,
                                    maxHeightDiskCache: 400,
                                    maxWidthDiskCache: 200,
                                    width: 120,
                                    imageUrl: staff.image!.large!,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Flexible(
                                  child: Text(
                                    staff.name!.full!,
                                    style: themeData.textTheme.titleSmall,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        if (_contentInformation.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Nenhum dado encontrado.'),
            ),
          )
      ],
    );
  }
}

class _OverlayColor extends WidgetStateProperty<Color?> {
  _OverlayColor(this._context);
  final BuildContext _context;

  ColorScheme get _colorScheme => Theme.of(_context).colorScheme;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return _colorScheme.primary.withOpacity(0.12);
    } else if (states.contains(WidgetState.hovered)) {
      return _colorScheme.primary.withOpacity(0.08);
    } else if (states.contains(WidgetState.focused)) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }
}
