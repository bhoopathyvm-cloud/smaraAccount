import 'package:flutter/material.dart';

/// A dropdown for picking one entity of type [T] by id from [items].
/// Callers own any filtering of [items] before passing them in - this
/// widget is filter-agnostic.
class EntityPickerField<T> extends StatelessWidget {
  const EntityPickerField({
    super.key,
    required this.labelText,
    required this.items,
    required this.idOf,
    required this.labelOf,
    required this.value,
    required this.onChanged,
  });

  final String labelText;
  final List<T> items;
  final String Function(T item) idOf;
  final String Function(T item) labelOf;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: labelText),
      items: [
        for (final item in items)
          DropdownMenuItem(value: idOf(item), child: Text(labelOf(item))),
      ],
      onChanged: onChanged,
    );
  }
}
