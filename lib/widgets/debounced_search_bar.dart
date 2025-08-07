import 'package:flutter/material.dart';
import 'dart:async';

typedef SearchFunction<T> = Future<Iterable<T>> Function(String query);

class DebouncedSearchBar<T> extends StatefulWidget {
  const DebouncedSearchBar({
    super.key,
    required this.onResultSelected,
    required this.searchFunction,
    required this.titleBuilder,
    this.hintText,
    this.initialValue,
    this.leadingIconBuilder,
    this.subtitleBuilder,
  });

  final String? hintText;
  final T? initialValue;
  final Widget? Function(T result)? titleBuilder;
  final Widget? Function(T result)? subtitleBuilder;
  final Widget? Function(T result)? leadingIconBuilder;
  final Function(T result) onResultSelected;
  final SearchFunction<T> searchFunction;

  @override
  State<DebouncedSearchBar<T>> createState() => _DebouncedSearchBarState<T>();
}

class _DebouncedSearchBarState<T> extends State<DebouncedSearchBar<T>> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  List<T> _results = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue.toString();
    }
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final results = await widget.searchFunction(_controller.text);
      if (mounted) {
        setState(() {
          _results = results.toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search',
            prefixIcon: widget.leadingIconBuilder != null && _results.isNotEmpty
                ? widget.leadingIconBuilder!(_results.first)
                : null,
          ),
        ),
        if (_results.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final item = _results[index];
              return ListTile(
                title: widget.titleBuilder?.call(item),
                subtitle: widget.subtitleBuilder?.call(item),
                leading: widget.leadingIconBuilder?.call(item),
                onTap: () {
                  widget.onResultSelected(item);
                  _controller.text = item.toString();
                  setState(() {
                    _results = [];
                  });
                },
              );
            },
          ),
      ],
    );
  }
}
