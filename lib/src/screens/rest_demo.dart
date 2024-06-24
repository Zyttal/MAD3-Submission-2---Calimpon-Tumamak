import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/models/user.model.dart';
import 'package:state_change_demo/src/screens/add_screen.dart';
import 'package:state_change_demo/src/screens/edit_screen.dart';
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => AddScreen(
                          controller: controller,
                          userController: usercontroller)),
                );
                //controller.getPost();
                //showNewPostFunction(context);
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
                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Post post in controller.postList)
                          GestureDetector(
                            onTap: () => _dialogBuilder(
                                context,
                                post,
                                usercontroller.getUser(post.userId).name,
                                controller),
                            child: SummaryCard(
                              post: post,
                              usercontroller: usercontroller,
                              username:
                                  usercontroller.getUser(post.userId).name,
                            ),
                          ),
                      ],
                    ));
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

Future<void> _dialogBuilder(BuildContext context, Post post, String username,
    PostController controller) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          post.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Colors.purple,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.body,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 37, 37, 37),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'by $username',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 37, 37, 37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditScreen(
                            post: post,
                            username: username,
                            controller: controller,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 118, 34, 133),
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Edit Post',
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.deletePost(post.id);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 141, 37, 63),
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Delete Post',
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
              ],
            ),
          ),
        ),
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
  List<Post> postList = [];
  bool working = true;
  Object? error;
  int lastPostCounter = 0;

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
      print(posts);
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

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      int limit = 3;

      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts?_limit=$limit");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      print(posts);
      postList = tmpPost;
      lastPostCounter = limit + 1;
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

  Future<Post> getPost() async {
    try {
      working = true;
      notifyListeners();

      final response = await http.get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts/$lastPostCounter"));

      if (response.statusCode != 200) {
        throw Exception("${response.statusCode} | ${response.body}");
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      final Post newPost = Post.fromJson(result);

      posts[newPost.id.toString()] = newPost;
      postList.add(newPost);
      lastPostCounter++;

      working = false;
      notifyListeners();
      return newPost;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      throw Exception("Failed to fetch post");
    }
  }

  Future<void> updatePost(Post updatedPost) async {
    try {
      working = true;
      if (error != null) error = null;

      http.Response res = await HttpService.put(
        url: "https://jsonplaceholder.typicode.com/posts/${updatedPost.id}",
        body: updatedPost.toJson(),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      Map<String, dynamic> result = jsonDecode(res.body);

      posts[result['id'].toString()] = Post.fromJson(result);

      int index = postList.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        postList[index] = Post.fromJson(result);
      }

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
      if (error != null) error = null;

      http.Response res = await HttpService.delete(
        url: "https://jsonplaceholder.typicode.com/posts/$id",
      );

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      posts.remove(id.toString());
      postList.removeWhere((post) => post.id == id);

      working = false;
      notifyListeners();
    } catch (e, st) {
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

  User getUser(int id) => userList.firstWhere((user) => user.id == id);

  Future<List<String>> getUsers() async {
    try {
      working = true;
      List result = [];
      int limit = 3;
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/users?_limit=$limit");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
      users = {for (User u in tmpUser) "${u.id}": u};
      working = false;
      notifyListeners();

      return tmpUser.map((user) => user.username).toList();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return [];
    }
  }

  // getUsers() async {
  //   try {
  //     working = true;
  //     List result = [];
  //     http.Response res = await HttpService.get(
  //         url: "https://jsonplaceholder.typicode.com/users");
  //     if (res.statusCode != 200 && res.statusCode != 201) {
  //       throw Exception("${res.statusCode} | ${res.body}");
  //     }
  //     result = jsonDecode(res.body);

  //     List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
  //     users = {for (User u in tmpUser) "${u.id}": u};
  //     working = false;
  //     notifyListeners();
  //   } catch (e, st) {
  //     print(e);
  //     print(st);
  //     error = e;
  //     working = false;
  //     notifyListeners();
  //   }
  // }

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

  static Future<http.Response> put(
      {required String url,
      required Map<String, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> delete(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.delete(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }
}
