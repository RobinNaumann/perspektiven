import 'package:elbe/bit/bit/bit_control.dart';
import 'package:newsy/service/s_news.dart';
import 'package:newsy/service/s_outlets.dart';

class ArticleGroup {
  final List<NewsArticle> articles;
  final NewsOutlet outlet;
  const ArticleGroup({required this.articles, required this.outlet});
}

class ArticleState {
  final NewsArticle article;
  final NewsOutlet currentOutlet;
  final List<ArticleGroup> groups;
  ArticleState(
      {required this.groups,
      required this.currentOutlet,
      required this.article});
}

class ArticleBit extends MapMsgBitControl<ArticleState> {
  static const builder = MapMsgBitBuilder<ArticleState, ArticleBit>.make;

  ArticleBit({required String url})
      : super.worker((_) async {
          final news = NewsService.i;
          final article = await news.getArticle(url);
          List<NewsArticle> articles =
              await news.getSimilar(article.keywords ?? []);

          final currentOutlet = OutletService.i.get(article.source!);
          final outlets = OutletService.i.opposed(currentOutlet);

          final groups = outlets
              .map((e) => e.$2)
              .map((outlet) => ArticleGroup(
                  articles: articles
                      .where((a) => a.source?.endsWith(outlet.host) ?? false)
                      .toList(),
                  outlet: outlet))
              .where((g) => g.articles.isNotEmpty)
              .toList();

          return ArticleState(
              article: article, currentOutlet: currentOutlet, groups: groups);
        });
}
