import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String hint;

  const SearchField({super.key, required this.hint});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            fillColor: Colors.grey),
        // onSubmitted: (String value) async {
        //   await showDialog<void>(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text('Thanks!'),
        //         content: Text(
        //             'You typed "$value", which has length ${value.characters.length}.'),
        //         actions: <Widget>[
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //             child: const Text('OK'),
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // },
      );
}