import 'package:flutter/material.dart';
import 'filter_sheet.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final Function(FilterData)? onFilterApplied;
  final FilterData? currentFilters;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this. controller,
    required this.onSubmitted,
    this.onFilterApplied,
    this.currentFilters,
    this.hintText = "Sportler, Disziplin oder Ort",
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool get hasActiveFilters => widget.currentFilters?. hasActiveFilters ?? false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:  const BoxConstraints(maxWidth:  420),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow:  [
            BoxShadow(
              color: Colors.black. withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons. search),
            suffixIcon: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.tune),
                  if (hasActiveFilters)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color:  Colors.deepPurple,
                          shape:  BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                final filterData = await showModalBottomSheet<FilterData>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FilterSheet(
                    initialFilters: widget.currentFilters,
                  ),
                );

                if (filterData != null && widget.onFilterApplied != null) {
                  widget.onFilterApplied!(filterData);
                }
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
          ),
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}