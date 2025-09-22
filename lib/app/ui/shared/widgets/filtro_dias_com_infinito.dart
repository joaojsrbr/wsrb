import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltroDiasComInfinito extends StatefulWidget {
  final void Function(DateTime? start, DateTime? end, bool dataInfinita)? onChanged;
  final VoidCallback? onClear;
  final DateTimeRange? current;
  final bool? isInfinite;
  const FiltroDiasComInfinito({
    super.key,
    this.onChanged,
    this.onClear,
    this.current,
    this.isInfinite,
  });

  @override
  State<FiltroDiasComInfinito> createState() => _FiltroDiasComInfinitoState();
}

class _FiltroDiasComInfinitoState extends State<FiltroDiasComInfinito> {
  final DateTime startDate = DateTime(DateTime.now().year, DateTime.january, 1);
  final DateTime endDate = DateTime.now();
  late int totalDays;

  RangeValues? _range;
  bool isInfinite = false;

  @override
  void initState() {
    super.initState();

    totalDays = endDate.difference(startDate).inDays;

    if (widget.current != null) {
      final start = widget.current!.start;
      final end = widget.current!.end;

      isInfinite = widget.isInfinite ?? start == DateTime(0);
      final startDays = isInfinite ? 0.0 : start.difference(startDate).inDays.toDouble();
      final endDays = end.difference(startDate).inDays.toDouble();

      _range = RangeValues(startDays, endDays);
    } else {
      isInfinite = widget.isInfinite ?? false;
      _range = null;
      // _range = RangeValues(0, totalDays.toDouble());
    }
  }

  String _formatDay(double days) {
    DateTime d = startDate.add(Duration(days: days.toInt()));
    return DateFormat('dd/MM').format(d);
  }

  // String get _rangeText {
  //   if (_range == null) return "Selecione...";
  //   if (isInfinite) return 'De ∞ até ${_formatDay(_range!.end)}';
  //   return '${_formatDay(_range!.start)} - ${_formatDay(_range!.end)}';
  // }

  void _abrirModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        RangeValues tempRange = _range ?? RangeValues(0, totalDays.toDouble());
        bool tempInfinito = isInfinite;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Intervalo de dias',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tempInfinito ? 'De ∞' : 'De ${_formatDay(tempRange.start)}'),
                      Text('Até ${_formatDay(tempRange.end)}'),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context),
                    child: RangeSlider(
                      values: tempRange,
                      min: 0,
                      max: totalDays.toDouble(),
                      divisions: totalDays,
                      labels: RangeLabels(
                        tempInfinito ? '∞' : _formatDay(tempRange.start),
                        _formatDay(tempRange.end),
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempRange = values;
                        });
                      },
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Início infinito (desde sempre)'),
                    value: tempInfinito,
                    onChanged: (v) => setModalState(() {
                      tempInfinito = v ?? false;
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _range = null;
                            isInfinite = false;
                          });
                          widget.onClear?.call();
                          Navigator.pop(context);
                        },
                        child: const Text("Limpar"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _range = tempRange;
                            isInfinite = tempInfinito;
                          });

                          final DateTime? start = tempInfinito
                              ? null
                              : startDate.add(Duration(days: tempRange.start.toInt()));
                          final DateTime end = startDate.add(
                            Duration(days: tempRange.end.toInt()),
                          );

                          widget.onChanged?.call(start, end, isInfinite);
                          Navigator.pop(context);
                        },
                        child: const Text("Aplicar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Intervalo de dias",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _abrirModal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_range == null) ...[
                    const Chip(
                      label: Text("Selecione..."),
                      avatar: Icon(Icons.date_range),
                    ),
                  ] else ...[
                    if (!isInfinite)
                      Chip(
                        label: Text('De ${_formatDay(_range!.start)}'),
                        avatar: const Icon(Icons.calendar_today),
                      )
                    else
                      const Chip(label: Text('De ∞'), avatar: Icon(Icons.calendar_today)),
                    Chip(
                      label: Text('Até ${_formatDay(_range!.end)}'),
                      avatar: const Icon(Icons.arrow_forward),
                    ),
                    ActionChip(
                      label: const Text("Limpar"),
                      onPressed: () {
                        setState(() {
                          _range = null;
                          isInfinite = false;
                        });
                        widget.onClear?.call();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
