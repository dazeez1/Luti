import 'package:flutter/material.dart';


class AmenitiesUi extends StatefulWidget
{
  final String type;
  final int startValue;
  final Function decreaseValue;
  final Function increaseValue;

  const AmenitiesUi({super.key, required this.type, required this.startValue, required this.decreaseValue, required this.increaseValue});

  @override
  State<AmenitiesUi> createState() => _AmenitiesUiState();
}

class _AmenitiesUiState extends State<AmenitiesUi> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.type,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                widget.decreaseValue();
              },
            ),
            Text(
              widget.startValue.toString(),
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                widget.increaseValue();
              },
            ),
          ],
        )
      ],
    );
  }
}
