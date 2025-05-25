import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:expense_tracker/models/categories_data.dart';
import 'package:flutter/material.dart';

class CustomDropdownExample extends StatefulWidget {
  const CustomDropdownExample({super.key});

  @override
  State<CustomDropdownExample> createState() => _CustomDropdownExampleState();
}

class _CustomDropdownExampleState extends State<CustomDropdownExample> {
  Category _selectedCategory = categoryMap['others']!;
  String? _selectedValue;

  Future<List<String>> getFakeRequestData(String query) async {
    List<String> data = _selectedCategory.label.split(' ');

    return await Future.delayed(const Duration(seconds: 1), () {
      return data
          .where((e) => e.toLowerCase().contains(query.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>.searchRequest(
      futureRequest: getFakeRequestData,
      hintBuilder: (context, hint, enabled) {
        return Text(
          hint.toUpperCase(),
          style: const TextStyle(color: Colors.black),
        );
      },
      hintText: 'Select Category',
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
      },
      futureRequestDelay: const Duration(seconds: 1),
    );
  }
}
