import 'package:flutter/material.dart';
import '../../config/tokens.dart';
import '../../services/instituciones_catalog_service.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;

  /// Texto visible por ítem; por defecto el propio valor.
  final String Function(String item)? itemLabel;

  /// Abre una hoja con buscador en vez del menú (listas largas).
  final bool searchable;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
    this.itemLabel,
    this.searchable = false,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _isFocused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  InputDecoration _decoration(ColorScheme scheme, Color iconColor) {
    return InputDecoration(
      hintText: widget.hintText ?? 'Seleccione ${widget.label.toLowerCase()}',
      prefixIcon:
          widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: iconColor, size: 22)
              : null,
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.prefixIcon != null ? Insets.sm : Insets.xl,
        vertical: 18,
      ),
      filled: true,
      fillColor:
          widget.enabled
              ? (_isFocused
                  ? scheme.surfaceContainerLowest
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.45))
              : scheme.surfaceContainer,
    );
  }

  String _labelOf(String item) => widget.itemLabel?.call(item) ?? item;

  Widget _buildSearchable(BuildContext context, Color iconColor) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.items.contains(widget.value) ? widget.value : null;
    return FormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      validator:
          widget.enabled
              ? (_) =>
                  selected == null ? 'Por favor seleccione una opción' : null
              : null,
      builder:
          (field) => Semantics(
            button: true,
            label: widget.label,
            value: selected == null ? null : _labelOf(selected),
            child: InkWell(
              focusNode: _focusNode,
              borderRadius: Radii.input,
              onTap:
                  widget.enabled ? () => _openSearch(context, selected) : null,
              child: InputDecorator(
                isFocused: _isFocused,
                isEmpty: selected == null,
                decoration: _decoration(scheme, iconColor).copyWith(
                  enabled: widget.enabled,
                  errorText: field.errorText,
                  suffixIcon: Icon(Icons.search_rounded, color: iconColor),
                ),
                child:
                    selected == null
                        ? null
                        : Text(
                          _labelOf(selected),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
              ),
            ),
          ),
    );
  }

  Future<void> _openSearch(BuildContext context, String? selected) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
      builder:
          (_) => _SearchSheet(
            title: widget.label.replaceAll('*', '').trim(),
            items: widget.items.toSet().toList(),
            labelOf: _labelOf,
            selected: selected,
          ),
    );
    if (result != null && result != selected) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focusColor = scheme.primary;
    final iconColor = _isFocused ? focusColor : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Insets.xs, bottom: Insets.sm),
            child: Text(
              widget.label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _isFocused ? focusColor : scheme.onSurface,
              ),
            ),
          ),
          if (widget.searchable)
            _buildSearchable(context, iconColor)
          else
            DropdownButtonFormField<String>(
              value: widget.items.contains(widget.value) ? widget.value : null,
              focusNode: _focusNode,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: _decoration(scheme, iconColor),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: iconColor,
                size: 24,
              ),
              dropdownColor: scheme.surfaceContainerLowest,
              borderRadius: Radii.card,
              // toSet(): valores repetidos harían fallar DropdownButton.
              items:
                  widget.items
                      .toSet()
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            widget.itemLabel?.call(item) ?? item,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              // Valor elegido en una línea con "…" (las etiquetas largas se cortan).
              selectedItemBuilder:
                  (context) =>
                      widget.items
                          .toSet()
                          .map(
                            (item) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.itemLabel?.call(item) ?? item,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
              onChanged: widget.enabled ? widget.onChanged : null,
              isExpanded: true,
              validator:
                  widget.enabled
                      ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una opción';
                        }
                        return null;
                      }
                      : null,
            ),
        ],
      ),
    );
  }
}

/// Hoja inferior con buscador (ignora mayúsculas y tildes; busca también
/// por el valor, p. ej. el código DANE).
class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.selected,
  });

  final String title;
  final List<String> items;
  final String Function(String) labelOf;
  final String? selected;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _queryCtrl = TextEditingController();
  late final _index = {
    for (final item in widget.items)
      item: InstitucionesCatalogService.normalizeKey(
        '${widget.labelOf(item)} $item',
      ),
  };
  late List<String> _results = widget.items;

  void _filter(String query) {
    final terms =
        InstitucionesCatalogService.normalizeKey(
          query,
        ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    setState(() {
      _results =
          terms.isEmpty
              ? widget.items
              : widget.items
                  .where((i) => terms.every(_index[i]!.contains))
                  .toList();
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                0,
                Insets.xl,
                Insets.md,
              ),
              child: Text(widget.title, style: theme.textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
              child: TextField(
                controller: _queryCtrl,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o código DANE',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _queryCtrl.text.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _queryCtrl.clear();
                              _filter('');
                            },
                          ),
                ),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Insets.xl,
                  Insets.sm,
                  Insets.xl,
                  Insets.xs,
                ),
                child: Text(
                  '${_results.length} de ${widget.items.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _results.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Insets.xl),
                          child: Text(
                            'Sin resultados para "${_queryCtrl.text}".\n'
                            'Pruebe con menos palabras o el código DANE.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          final item = _results[i];
                          final isSelected = item == widget.selected;
                          return ListTile(
                            minTileHeight: 56,
                            selected: isSelected,
                            title: Text(widget.labelOf(item)),
                            trailing:
                                isSelected
                                    ? const Icon(Icons.check_rounded)
                                    : null,
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
