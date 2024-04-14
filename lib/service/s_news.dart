import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:elbe/util/m_data.dart';
import 'package:newsy/service/s_outlets.dart';

class NewsArticle extends DataModel {
  final String title;
  final String? description;
  final String? urlToImage;
  final String? url;
  final List<String>? keywords;
  final String? source;

  NewsArticle({
    required this.source,
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    this.keywords,
  });

  @override
  get map => {
        "title": title,
        "description": description,
        "urlToImage": urlToImage,
        "url": url,
        "keywords": keywords,
        "source": source,
      };
}

class NewsService {
  static final NewsService i = NewsService._();
  NewsService._();

  Future<NewsArticle> getArticle(String url) async {
    final response = await http.get(Uri.parse(url));
    final head = parse(response.body).querySelector("head");

    final host = Uri.parse(url).host;

    final title = head
            ?.querySelector("meta[property='og:title']")
            ?.attributes["content"] ??
        head?.querySelector("title")?.text;

    final keywords = head
        ?.querySelector("meta[name='news_keywords']")
        ?.attributes["content"]
        ?.split(",")
        .map((e) => e.trim());

    return NewsArticle(
        source: host,
        title: title ?? "unknown article",
        description: head
            ?.querySelector("meta[name='description']")
            ?.attributes["content"],
        urlToImage: head
            ?.querySelector("meta[property='og:image']")
            ?.attributes["content"],
        url: url,
        keywords: (keywords?.isNotEmpty ?? false)
            ? keywords!.skip(1).take(5).toList()
            : (title != null ? [title] : null));
  }

  Future<List<NewsArticle>> getSimilar(List<String> keywords) async {
    print("getting similar articles based on: $keywords");

    String query = keywords.map((e) => e.replaceAll(" ", "+")).join("+");
    List<String> sites = [];

    for (final outlet in OutletService.i.outlets) {
      sites.add("site:${outlet.host}");
    }

    String url =
        "https://news.google.com/rss/search?q=$query+when:21d+${sites.join("+OR+")}&hl=de&gl=DE";

    final rss = await http.get(Uri.parse(url));
    final items =
        parse(rss.body.replaceAll("&gt;", ">").replaceAll("&lt;", "<"))
            .querySelectorAll("item");

    return items
        .map((e) => NewsArticle(
            source: e.querySelector("source")?.attributes["url"],
            title: e.querySelector("title")?.text ?? "unknown article",
            description:
                e.querySelector("description")?.querySelector("a")?.innerHtml,
            url: e.querySelector("description a")?.attributes["href"]?.trim(),
            keywords: []))
        .toList();
  }
}
