import 'package:flutter/material.dart';
import 'package:state_change_demo/global_styles.dart';
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.post,
    required this.usercontroller,
    required this.username,
  });

  final Post post;
  final UserController usercontroller;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [kboxShadow]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title.length > 20
                  ? '${post.title.substring(0, 50)}...'
                  : post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2, // Adjust the height value as needed
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("- $username"),
              ],
            )
          ],
        ));
  }
}
