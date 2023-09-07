import 'package:flutter/material.dart';
import 'assets/colors.dart' as colors;

class CustomRadioButtonGroup extends StatelessWidget {
  final List<String> options;
  final String zeichenAuswahl;
  final ValueChanged<String> onChanged;

  const CustomRadioButtonGroup({
    super.key,
    required this.options,
    required this.zeichenAuswahl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((option) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / (options.length + 0.5),
          child: CustomRadioButton(
            text: option,
            isSelected: zeichenAuswahl == option,
            onChanged: () {
              onChanged(option);
            },
          ),
        );
      }).toList(),
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onChanged;

  const CustomRadioButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onChanged,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? colors.teal : Colors.white,
        side: BorderSide(
          color: isSelected ? colors.teal : Colors.grey,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}

class CustomMultiSelectRadio extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onChanged;

  CustomMultiSelectRadio({
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  _CustomMultiSelectRadioState createState() => _CustomMultiSelectRadioState();
}

class _CustomMultiSelectRadioState extends State<CustomMultiSelectRadio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        bool isSelected = widget.selectedOptions.contains(option);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: SizedBox(
            width: 120,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? colors.teal : Colors.white,
                side: BorderSide(
                  color: isSelected ? colors.teal : Colors.grey,
                ),
              ),
              onPressed: () {
                setState(() {
                  if (isSelected && widget.selectedOptions.length > 1) {
                    widget.selectedOptions.remove(option);
                  } else if (!isSelected) {
                    widget.selectedOptions.add(option);
                  }
                  widget.onChanged(widget.selectedOptions);
                });
              },
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
