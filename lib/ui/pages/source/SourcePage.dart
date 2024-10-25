// Sample Source Page
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feed/data/Const.dart';
import 'package:flutter_feed/ui/pages/source/FeedSource.dart';
import 'package:http/http.dart' as http;

class SourcePage extends StatefulWidget {
  @override
  _SourcePageState createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  bool isLoading = true;
  List<FeedSource> feedItems = [];

  Future<void> fetchFeed() async {
    try {
      final response = await http.get(Uri.parse(url_source));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> sources = data['source'];
        setState(() {
          feedItems = sources.map((item) => FeedSource.fromJson(item)).toList();
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

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Feed Sources')),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
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
                      onPressed: () {
                        // Handle follow button action
                        print('Followed ${feedItems[index].title}');
                      },
                      child: Text('Follow'),
                    ),
                    onTap: () {
                      // Handle tap event, e.g., open the URL
                      print('Tapped on ${feedItems[index].url}');
                    },
                  );
                },
              ),
      ),
    );
  }
}
