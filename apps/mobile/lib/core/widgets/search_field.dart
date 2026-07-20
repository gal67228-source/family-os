import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.hintText,
    this.onChanged,
    super.key,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: hintText,
      leading: const Icon(Icons.search_rounded),
      onChanged: onChanged,
    );
  }
}
