import 'package:elbe/bit/bit.dart';
import 'package:elbe/elbe.dart';
import 'package:newsy/bit/b_article.dart';
import 'package:newsy/main.dart';
import 'package:newsy/service/s_news.dart';
import 'package:newsy/service/s_outlets.dart';
import 'package:newsy/view/v_chart.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticlePage extends StatelessWidget {
  final String newsUrl;
  const ArticlePage({super.key, required this.newsUrl});

  @override
  Widget build(BuildContext context) {
    return BitProvider(
        create: (_) => ArticleBit(url: newsUrl),
        child: ArticleBit.builder(
            onLoading: (bit, loading) => Scaffold(
                title: "",
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fileSearch),
                        const Text("analysiere...",
                            textAlign: TextAlign.center),
                      ].spaced(),
                    ),
                  ].spaced(amount: 3),
                )),
            onError: (bit, error) => const Scaffold(
                  leadingIcon: LeadingIcon.close(),
                  actions: [ThemeToggleBtn()],
                  title: "Artikel",
                  child: Center(
                    child: Text("Artikel konnte\nnicht geladen\nwerden"),
                  ),
                ),
            onData: (bit, data) => HeroScaffold(
                  hero: Image.network(
                    data.article.urlToImage!,
                    fit: BoxFit.cover,
                  ),
                  actions: const [ThemeToggleBtn()],
                  leadingIcon: const LeadingIcon.close(),
                  title: "Artikel",
                  body: Padded.only(
                    left: 1,
                    right: 1,
                    bottom: 1,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text.h3(data.article.title),
                          OutletSnippet(outlet: data.currentOutlet),
                          Text(data.article.description ?? ""),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text.h6(
                                    "Leserschaft von ${data.currentOutlet.name}"),
                                InkWell(
                                  onTap: () => launchUrlString(
                                      "https://agma-mmc.de",
                                      mode: LaunchMode.externalApplication),
                                  child: const Text.bodyS("Daten von agma e.V.",
                                      variant: TypeVariants.italic),
                                ),
                              ]),
                          Center(
                            child: OutletAudienceChart(
                              outlets: [data.currentOutlet],
                              color1: ColorTheme.of(context)
                                  .activeScheme
                                  .majorAccent,
                              color2: Colors.transparent,
                            ),
                          ),
                          const Spaced(),
                          Text.h6("andere Perspektiven"),
                          if (data.groups.isEmpty)
                            const Text("keine weiteren Perspektiven")
                          else
                            for (final g in data.groups)
                              ArticleGroupView(
                                  currentOutlet: data.currentOutlet, group: g)
                        ].spaced(amount: 1)),
                  ),
                )));
  }
}

class ArticleGroupView extends StatelessWidget {
  final NewsOutlet currentOutlet;
  final ArticleGroup group;
  const ArticleGroupView(
      {super.key, required this.currentOutlet, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutletAudienceChart(
              outlets: [currentOutlet, group.outlet],
              color1: ColorTheme.of(context).activeScheme.majorAccent,
              color2: ColorTheme.of(context).activeScheme.minorAccent,
              size: 4),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutletSnippet(outlet: group.outlet),
                    for (final article in group.articles.take(3))
                      ArticleSnippet(article: article)
                  ].spaced()))
        ].spaced(),
      ),
    );
  }
}

class ArticleSnippet extends StatelessWidget {
  final NewsArticle article;
  const ArticleSnippet({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (article.url?.isNotEmpty ?? false) {
            launchUrlString(article.url!, mode: LaunchMode.externalApplication);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("kein Link verfügbar",
                color: ColorTheme.of(context)
                    .activeMode
                    .inverse
                    .plain
                    .neutral
                    .front),
          ));
        },
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text.h6(article.title, resolvedStyle: TypeStyle(fontSize: 1)),
          Text(article.description ?? ""),
        ]));
  }
}

class OutletSnippet extends StatelessWidget {
  final NewsOutlet outlet;

  const OutletSnippet({super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    final cred = outlet.rating?.credibility;
    return Row(
      children: [
        Expanded(child: Text(outlet.name, variant: TypeVariants.bold)),
        if (cred != null)
          Card(
              onTap: () => launchUrlString(
                  outlet.rating?.sourceUrl ?? "https://mediabiasfactcheck.com/",
                  mode: LaunchMode.externalApplication),
              padding:
                  const RemInsets.symmetric(vertical: 0.2, horizontal: 0.3),
              style: cred > 0.5
                  ? ColorStyles.minorAlertSuccess
                  : ColorStyles.minorAlertWarning,
              child: Text(
                  cred > 0.6
                      ? "verlässlich"
                      : (cred > 0.4 ? "mäßig" : "unverlässlich"),
                  variant: TypeVariants.bold))
      ],
    );
  }
}
