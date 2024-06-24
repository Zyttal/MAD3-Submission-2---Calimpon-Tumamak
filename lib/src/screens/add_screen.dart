import 'package:flutter/material.dart';
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/screens/rest_demo.dart';

class AddScreen extends StatefulWidget {
  final PostController controller;
  final UserController userController;

  const AddScreen({
    Key? key,
    required this.controller,
    required this.userController,
  }) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late TextEditingController titleController;
  late TextEditingController bodyController;
  late String selectedUsername;
  List<String> usernames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: '');
    bodyController = TextEditingController(text: '');
    selectedUsername = '';

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      List<String> fetchedUsernames = await widget.userController.getUsers();
      setState(() {
        usernames = fetchedUsernames;
        if (usernames.isNotEmpty) {
          selectedUsername = usernames[0];
        }
      });

      setState(() {
        titleController.text = '';
        bodyController.text = '';
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing screen: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Post newPost = await widget.controller.getPost();
                        final updatedPost = newPost.copyWith(
                          title: titleController.text.trim(),
                          body: bodyController.text.trim(),
                        );

                        await widget.controller.updatePost(updatedPost);

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 125, 37, 141),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Add New Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
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
