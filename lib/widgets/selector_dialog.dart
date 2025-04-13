import 'package:flutter/material.dart';

// A generic dialog for selecting an item from a list using RadioListTile
class SelectorDialog<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T currentItem;
  final Widget Function(T item) itemBuilder; // Function to build list tile title
  final ValueChanged<T> onItemSelected;

  const SelectorDialog({
    super.key,
    required this.title,
    required this.items,
    required this.currentItem,
    required this.itemBuilder,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      // Constrain content size and make it scrollable if needed
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding
      content: SizedBox(
        width: double.maxFinite, // Use available width
        // Use ConstrainedBox to limit height if list is very long
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5, // Max 50% of screen height
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final bool isSelected = item == currentItem;
              return RadioListTile<T>(
                title: itemBuilder(item), // Use the builder for the title
                value: item,
                groupValue: currentItem,
                onChanged: (T? value) {
                  if (value != null) {
                    onItemSelected(value);
                    // Optionally close dialog immediately after selection:
                    // Navigator.of(context).pop();
                  }
                },
                selected: isSelected,
                activeColor: Theme.of(context).colorScheme.primary, // Use theme color
                // Add some padding within the list tile
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              );
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'), // Changed from Cancel
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
