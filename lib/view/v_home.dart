import 'package:elbe/elbe.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:newsy/main.dart';
import 'package:newsy/view/v_article_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        leadingIcon: LeadingIcon.none(),
        actions: [ThemeToggleBtn()],
        title: "Perspektiven",
        child: _ShareToView());
  }
}

class _ShareToView extends StatefulWidget {
  const _ShareToView({super.key});

  @override
  State<_ShareToView> createState() => _ShareToViewState();
}

class _ShareToViewState extends State<_ShareToView> {
  String? error;

  void setError(String msg) {
    setState(() => error = msg);
  }

  @override
  void initState() {
    super.initState();
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      final shared = value.firstOrNull;
      if (shared == null) return;
      if (shared.type != SharedMediaType.TEXT) {
        return setError("Die App versteht nur Text");
      }

      final link = shared.value
          ?.split(RegExp(r'\s'))
          .firstWhereOrNull((e) => e.trim().startsWith("https://"));

      if (link == null) return setError("es wurde kein Link gefunden");
      setState(() => error = null);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ArticlePage(newsUrl: link)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padded.all(
      value: 2,
      child: Column(
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (error != null)
                    Card(
                        style: ColorStyles.minorAlertError,
                        margin: const RemInsets(bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.alertTriangle),
                            Text(error ?? "")
                          ].spaced(),
                        )),
                  const Icon(Icons.share2),
                  Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 290),
                        child: const Text(
                            "teile einen Nachrichtenartikel aus dem Browser oder deiner Nachrichten-App, um dir andere Perspektiven zum gleichen Thema anzusehen",
                            textAlign: TextAlign.center)),
                  ),
                ].spaced()),
          ),
          Row(
            children: [
              Expanded(
                  child: const Button.integrated(
                      icon: Icons.globe2, label: "website")),
              Expanded(
                  child: const Button.integrated(
                      icon: Icons.github, label: "source"))
            ],
          ),
        ],
      ),
    );
  }
}
