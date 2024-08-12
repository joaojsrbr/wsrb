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
  String substring = "";
  bool isOver100 = false;
  bool _expanded = false;
  final Map<String, Widget> _contentInformation = {};
  late Content _content;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    _content = ContentScope.contentOf(context);

    if (!_expanded) isOver100 = substring.length > 100;

    if (isOver100 && !_expanded) {
      substring = "${_content.sinopse?.substring(0, 100)} ...";
    }

    if (_content.animeMedia != null && mounted) {
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

    if (_content.animeMedia?.startDate?.isEmpty != true) {
      _contentInformation["Data de início"] = Text(
        key: ValueKey(DateTime(
          _content.animeMedia!.startDate!.year!,
          _content.animeMedia!.startDate!.month!,
          _content.animeMedia!.startDate!.day!,
        ).toString()),
        DateFormat("d MMMM y", appLocale.toLanguageTag()).format(
          DateTime(
            _content.animeMedia!.startDate!.year!,
            _content.animeMedia!.startDate!.month!,
            _content.animeMedia!.startDate!.day!,
          ),
        ),
      );
    }
    if (_content.animeMedia?.endDate?.isEmpty != true) {
      cache["Data final"] = Text(
        key: ValueKey(DateTime(
          _content.animeMedia!.endDate!.year!,
          _content.animeMedia!.endDate!.month!,
          _content.animeMedia!.endDate!.day!,
        ).toString()),
        DateFormat("d MMMM y", appLocale.toLanguageTag()).format(
          DateTime(
            _content.animeMedia!.endDate!.year!,
            _content.animeMedia!.endDate!.month!,
            _content.animeMedia!.endDate!.day!,
          ),
        ),
      );
    }
    if (_content.animeMedia?.averageScore != null) {
      cache["Pontuação"] = Text.rich(
        key: ValueKey((_content.animeMedia!.averageScore! / 10).toString()),
        TextSpan(
          children: [
            TextSpan(
              text: (_content.animeMedia!.averageScore! / 10).toString(),
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
    if (_content.animeMedia?.episodes != null) {
      cache["Total de episódios"] = Text(
        key: ValueKey(_content.animeMedia!.episodes.toString()),
        _content.animeMedia!.episodes.toString(),
      );
    }
    if (_content.animeMedia?.format != null) {
      cache["Formato"] = Text(
        key: ValueKey(_content.animeMedia!.format!.name),
        _content.animeMedia!.format!.name,
      );
    }
    if (_content.animeMedia?.status != null) {
      cache["Status"] = Text(
        key: ValueKey(_content.animeMedia!.status!.toString()),
        _content.animeMedia!.status!.toString(),
      );
    }
    if (_content.animeMedia?.popularity != null) {
      cache["Popularidade"] = Text(
        key: ValueKey(_content.animeMedia!.popularity!.toString()),
        _content.animeMedia!.popularity!.toString(),
      );
    }
    if (_content.animeMedia?.favourites != null) {
      cache["Favoritos"] = Text(
        key: ValueKey(_content.animeMedia!.favourites!.toString()),
        _content.animeMedia!.favourites!.toString(),
      );
    }
    if (_content.animeMedia?.season != null) {
      cache["Temporada"] = Text(
        key: ValueKey("${_content.animeMedia!.season!.name} ${now.year}"),
        "${_content.animeMedia!.season!.name} ${now.year}",
      );
    }
    if (_content.animeMedia?.title?.romaji != null) {
      cache["Nome Romaji"] = GestureDetector(
        onLongPress: () async {
          copyToClipboard(
            context,
            messageCopy: _content.animeMedia!.title!.romaji!,
            messageSnackBar: 'Copiado para a área de transferência!',
          );
          await Feedback.forLongPress(context);
        },
        child: Text(
          key: ValueKey(_content.animeMedia!.title!.romaji!),
          _content.animeMedia!.title!.romaji!,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData themeData = Theme.of(context);

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        if ((_expanded ? _content.sinopse ?? "" : substring).isNotEmpty)
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
                onTap: isOver100
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
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
                            child: Text(
                              _expanded ? _content.sinopse ?? "" : substring,
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
                top: (_expanded ? _content.sinopse ?? "" : substring).isEmpty
                    ? 8
                    : 0),
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
        if (_content.animeMedia?.genres != null)
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
                  children: _content.animeMedia!.genres!
                      .map((e) => e.capitalize)
                      .toList()
                      .unique()
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
        if (_content.animeMedia?.characters?.nodes != null)
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
                child: ListView.builder(
                  itemCount: _content.animeMedia?.characters?.nodes?.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final personagem =
                        _content.animeMedia?.characters?.nodes![index];
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
                                  imageUrl: personagem!.image!.large!,
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
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (_content.animeMedia?.staff?.nodes != null)
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
                child: ListView.builder(
                  itemCount: _content.animeMedia?.staff?.nodes?.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final staff = _content.animeMedia?.staff?.nodes![index];
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
                                  imageUrl: staff!.image!.large!,
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
                ),
              ),
            ],
          ),
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
