import 'package:flutter/material.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/board_card.dart';

class BoardsList extends StatelessWidget {
  const BoardsList({super.key, required this.boards});

  final List<Board> boards;

  @override
  Widget build(BuildContext context) => ListView.builder(
      itemCount: boards.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            BoardCard(board: boards[index]),
            if (index < boards.length - 1)
              const Divider(thickness: 1, indent: 16, endIndent: 16)
          ],
        );
      });
}