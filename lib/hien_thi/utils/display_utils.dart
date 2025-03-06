import 'package:flutter/material.dart';

enum SortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
}

class DisplayUtils {
  // Translate sort option to Vietnamese for display
  static String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.nameAZ:
        return 'A-Z';
      case SortOption.nameZA:
        return 'Z-A';
      case SortOption.dateNewest:
        return 'Mới nhất';
      case SortOption.dateOldest:
        return 'Cũ nhất';
    }
  }

  // Build a common app bar with search and sort functionality
  static AppBar buildSearchSortAppBar({
    required BuildContext context,
    required String title,
    required bool isSearching,
    required TextEditingController searchController,
    required SortOption currentSortOption,
    required Function(bool) onSearchToggle,
    required Function(String) onSearchChanged,
    required Function(SortOption) onSortChanged,
    bool showBackButton = true,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: !isSearching,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: onSearchChanged,
            )
          : Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      actions: [
        // Search button
        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: Colors.black,
          ),
          onPressed: () => onSearchToggle(!isSearching),
        ),
        // Sort button
        PopupMenuButton<SortOption>(
          icon: const Icon(Icons.sort, color: Colors.black),
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            _buildPopupMenuItem(SortOption.nameAZ, 'A-Z', currentSortOption),
            _buildPopupMenuItem(SortOption.nameZA, 'Z-A', currentSortOption),
            _buildPopupMenuItem(SortOption.dateNewest, 'Mới nhất', currentSortOption),
            _buildPopupMenuItem(SortOption.dateOldest, 'Cũ nhất', currentSortOption),
          ],
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  // Helper method to build popup menu items
  static PopupMenuItem<SortOption> _buildPopupMenuItem(
    SortOption option,
    String text,
    SortOption currentOption,
  ) {
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            option == currentOption ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: option == currentOption ? Colors.blue : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  // Animation for grid items
  static Widget animateGridItem(Widget child, int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + (index * 30)),
      curve: Curves.easeInOut,
      child: AnimatedPadding(
        padding: const EdgeInsets.all(0),
        duration: Duration(milliseconds: 300 + (index * 30)),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}