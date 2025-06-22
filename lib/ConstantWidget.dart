
import 'package:flutter/material.dart';

class ConstantWidgets {
  static Container textFieldContainer(
    TextEditingController controller,
    String text,
    int number,
    TextInputType type,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      alignment: Alignment.center,
      child: TextField(
        keyboardType: type,
        maxLines: number,
        controller: controller,
        style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: text,
          hintStyle: const TextStyle(color: Colors.black26),
          border: InputBorder.none,
        ),
      ),
    );
  }

  static Widget labeledCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFFDAA67B),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
