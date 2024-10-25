import 'package:flutter/material.dart';
import 'package:flutter_feed/database/DbManager.dart';
import 'package:flutter_feed/database/Model.dart';
import 'package:flutter_feed/ui/pages/source/SourcePage.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../rss/RssFeed.dart';
import '../../../rss/RssItem.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPreviewPage extends StatefulWidget {
  Model feedItem;

  FeedPreviewPage(this.feedItem);

  @override
  _FeedPreviewPageState createState() => _FeedPreviewPageState(feedItem);
}

class _FeedPreviewPageState extends State<FeedPreviewPage> {
  DbManager dbManager = DbManager();

  RssFeed1? _feed;
  bool _isLoading = true;
  List<RssItem1> items = [];

  Model feedItem;

  _FeedPreviewPageState(this.feedItem);

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await http.get(Uri.parse(feedItem.url));
      if (response.statusCode == 200) {
        setState(() {
          _feed = RssFeed1.parse(response.body);
          setState(() {
            items = [];
          });
          if (_feed != null) {
            if (_feed!.items != null) {
              items = _feed!.items!;
            }
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _toggleFollow(Model modelSource) async {
    var newModel = Model(
        url: modelSource.url,
        title: modelSource.title,
        icon: modelSource.icon,
        is_on: toggleInt(modelSource.is_on));
    await dbManager.updateModel(newModel);
    setState(() {
      feedItem = newModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSS Feed Preview'),
        actions: [
          TextButton(
            onPressed: () => {_toggleFollow(feedItem)},
            child: Text((feedItem.is_on == 1) ? "UnFollow" : "Follow"),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (items.isEmpty)
              ? Center(child: Text('No articles found.'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CachedNetworkImage(
                            imageUrl: getCorrectImage(
                                item), // Use media URL if available
                            imageBuilder: (context, imageProvider) => AspectRatio(
                              aspectRatio: 3 / 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(item.title?? '',  style: GoogleFonts.roboto(fontSize: 18)),
                        ),
                        Divider()
                      ],
                    );
                  },
                ),
    );
  }
}

String getCorrectImage(RssItem1 item) {
  var url= item.enclosure?.url ??
      item.featuredImage??
      item.media?.thumbnails?.firstOrNull?.url??
      item.media?.contents?.firstOrNull?.url??
      '';
  return url;
}
