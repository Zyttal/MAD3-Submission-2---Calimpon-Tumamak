import 'package:flutter/material.dart';
import 'package:state_change_demo/global_styles.dart';
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.post,
    required this.usercontroller,
  });

  final Post post;
  final UserController usercontroller;

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
              post.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("- ${usercontroller.getUser(post.userId).name}"),
              ],
            )
          ],
        ));
  }
}
