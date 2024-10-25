// Sample Source Page

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter_feed/data/Const.dart';
import 'package:flutter_feed/database/DbManager.dart';
import 'package:flutter_feed/database/Model.dart';
import 'package:flutter_feed/ui/pages/feed/FeedPreviewPage.dart';
import 'package:flutter_feed/ui/pages/source/FeedSource.dart';
import 'package:http/http.dart' as http;

class SourcePage extends StatefulWidget {
  @override
  _SourcePageState createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  DbManager dbManager = DbManager();
  List<Model> feedItems = [];
  bool isLoading = true;

  Future<void> fetchFeed() async {
    try {
      isLoading = true;
      List<Model> listdb = await dbManager.getModelList();
      final response = await http.get(Uri.parse(url_source));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> sources = data['source'];

        setState(() async {
          List<FeedSource> feedItems =
              sources.map((item) => FeedSource.fromJson(item)).toList();
          for (var source_model in feedItems) {
            var isOnOld = await checkIsOn(listdb, source_model.url);
            dbManager.insertModel(Model(
              url: source_model.url,
              title: source_model.title,
              icon: source_model.icon,
              is_on: isOnOld,
            ));
          }
          syncDb();
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int> checkIsOn(List<Model> list, String targetUrl) async {
    int is_on = 0;
    for (var value in list) {
      if (value.url == targetUrl) {
        is_on = value.is_on;
      }
    }
    return is_on;
  }

  syncDb() async {
    var list = await dbManager.getModelList();
    setState(() {
      feedItems = list;
    });
  }

  @override
  void initState() {
    super.initState();
    syncDb();
    fetchFeed();
  }

  Future<void> _handleRefresh() async {
    fetchFeed();
  }

  Future<void> _toggleFollow(Model modelSource) async {
    await dbManager.updateModel(Model(
        url: modelSource.url,
        title: modelSource.title,
        icon: modelSource.icon,
        is_on: toggleInt(modelSource.is_on)));
    syncDb();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Feed Sources')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  itemCount: feedItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(
                        feedItems[index].icon,
                        width: 35,
                        height: 35,
                      ),
                      title: Text(
                        feedItems[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        feedItems[index].url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      trailing: TextButton(
                        onPressed: () => {_toggleFollow(feedItems[index])},
                        child: Text((feedItems[index].is_on == 1)
                            ? "UnFollow"
                            : "Follow"),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FeedPreviewPage(feedItems[index])),
                        ).then((value) {
                          syncDb();
                        });
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

int toggleInt(int a) {
  if (a == 1) {
    return 0;
  } else {
    return 1;
  }
}
