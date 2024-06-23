import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/models/user.model.dart';
import 'package:state_change_demo/src/widgets/summary_card.dart';

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  State<RestDemoScreen> createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController controller = PostController();
  UserController usercontroller = UserController();

  @override
  void initState() {
    super.initState();
    controller.getPosts();
    usercontroller.getUsers();
    List<User> userList = usercontroller.userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        leading: IconButton(
            onPressed: () {
              controller.getPosts();
              usercontroller.getUsers();
            },
            icon: const Icon(Icons.refresh)),
        actions: [
          IconButton(
              onPressed: () {
                showNewPostFunction(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.error != null) {
                return Center(
                  child: Text(controller.error.toString()),
                );
              }

              if (!controller.working) {
                return Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (Post post in controller.postList)
                            GestureDetector(
                              onTap: () => _dialogBuilder(
                                  context,
                                  post,
                                  usercontroller.getUser(post.id)!.name,
                                  controller),
                              child: SummaryCard(
                                  post: post, usercontroller: usercontroller),
                            ),
                        ],
                      )),
                );
              }
              return const Center(
                child: SpinKitChasingDots(
                  size: 54,
                  color: Colors.black87,
                ),
              );
            }),
      ),
    );
  }

  showNewPostFunction(BuildContext context) {
    AddPostDialog.show(context, controller: controller);
  }
}

Future<void> _dialogBuilder(BuildContext context, Post post, String? username,
    PostController controller) async {
  TextEditingController titleController =
      TextEditingController(text: post.title);
  TextEditingController bodyController = TextEditingController(text: post.body);

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit Post", style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Content',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Post updatedPost = Post(
                id: post.id,
                title: titleController.text,
                body: bodyController.text,
                userId: post.userId,
              );

              controller.updatePostLocally(updatedPost);
              Navigator.of(context).pop();
            },
            child: Text("Update"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deletePost(post.id);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context, {required PostController controller}) =>
      showDialog(
          context: context, builder: (dContext) => AddPostDialog(controller));
  const AddPostDialog(this.controller, {super.key});

  final PostController controller;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController bodyC, titleC;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController();
    titleC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text("Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            widget.controller.makePost(
                title: titleC.text.trim(), body: bodyC.text.trim(), userId: 1);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title"),
          Flexible(
            child: TextFormField(
              controller: titleC,
            ),
          ),
          const Text("Content"),
          Flexible(
            child: TextFormField(
              controller: bodyC,
            ),
          ),
        ],
      ),
    );
  }
}

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  List<Post> postList = []; // Convert to a local List for UI
  bool working = true;
  Object? error;

  clear() {
    error = null;
    posts = {};
    postList = [];
    notifyListeners();
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      print(title);
      print(body);
      print(userId);
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      print(res.body);

      Map<String, dynamic> result = jsonDecode(res.body);

      Post output = Post.fromJson(result);
      posts[output.id.toString()] = output;
      working = false;
      notifyListeners();
      return output;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<void> updatePostLocally(Post updatedPost) async {
    try {
      working = true;
      if (error != null) error = null;

      int index = postList.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        postList[index] = updatedPost;
        posts[updatedPost.id.toString()] = updatedPost;
        notifyListeners();
      }

      working = false;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      postList = tmpPost;
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int id) async {
    try {
      working = true;
      notifyListeners();

      // Remove post from local state for UI Changes
      posts.remove(id.toString());
      postList.removeWhere((post) => post.id == id);

      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }
}

class UserController with ChangeNotifier {
  Map<String, dynamic> users = {};
  bool working = true;
  Object? error;

  List<User> get userList => users.values.whereType<User>().toList();
  User? getUser(int id) {
    // Check if the user exists in the map
    if (users.containsKey(id.toString())) {
      return users[id.toString()];
    } else {
      return const User(
          id: 0,
          name: "unk",
          username: "unk",
          email: "unk",
          address: Address(
              street: "unk",
              suite: "unk",
              city: "unk",
              zipcode: "unk",
              geo: Geo(lat: "unk", lng: "unk")),
          phone: "unk",
          website: "unk",
          company: Company(name: "unk", catchPhrase: "unk", bs: "unk"));
    }
  }

  getUsers() async {
    try {
      working = true;
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/users");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
      users = {for (User u in tmpUser) "${u.id}": u};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  clear() {
    users = {};
    notifyListeners();
  }
}

class HttpService {
  static Future<http.Response> get(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> post(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }
}
