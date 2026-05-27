import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotesSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String initialValue;

  const NotesSearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.initialValue = '',
  });

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;
    _ctrl.addListener(() {
      final has = _ctrl.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
      widget.onChanged(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _ctrl,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Поиск',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: AnimatedOpacity(
            opacity: _hasText ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
              onPressed: () {
                _ctrl.clear();
                widget.onClear();
              },
            ),
          ),
        ),
      ),
    );
  }
}
