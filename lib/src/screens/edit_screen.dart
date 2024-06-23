import 'package:flutter/material.dart';
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';

class EditScreen extends StatefulWidget {
  final Post post;
  final String username;
  final PostController controller;

  const EditScreen({
    super.key,
    required this.post,
    required this.username,
    required this.controller,
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController titleController;
  late TextEditingController bodyController;
  late TextEditingController usernameController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post.title);
    bodyController = TextEditingController(text: widget.post.body);
    usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            // const SizedBox(height: 10),
            // TextField(
            //   controller: usernameController,
            //   decoration: const InputDecoration(labelText: 'Username'),
            // ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updatedPost = widget.post.copyWith(
                    title: titleController.text.trim(),
                    body: bodyController.text.trim(),
                  );

                  //final updatedUsername = usernameController.text.trim();

                  await widget.controller.updatePost(updatedPost);

                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 125, 37, 141),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
