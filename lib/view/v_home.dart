import 'package:elbe/elbe.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:newsy/main.dart';
import 'package:newsy/view/v_article_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  load(String link) {
    setState(() => error = null);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ArticlePage(newsUrl: link)),
    );
  }

  void emit(String? link, String? error) {
    if (error != null) {
      setError(error);
      return;
    }
    if (link != null) {
      load(link);
    }
    listen();
  }

  listen() {
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      final shared = value.firstOrNull;
      if (shared == null) return;

      if (shared.type == SharedMediaType.URL && shared.value != null) {
        return emit(shared.value!, null);
      }

      if (shared.type != SharedMediaType.TEXT) {
        return emit(null, "Die App versteht nur Text");
      }

      final link = shared.value
          ?.split(RegExp(r'\s'))
          .firstWhereOrNull((e) => e.trim().startsWith("https://"));

      if (link == null) return emit(null, "es wurde kein Link gefunden");
      emit(link, null);
    });
  }

  @override
  void initState() {
    super.initState();
    listen();
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
                            "teile einen Nachrichtenartikel aus dem Browser oder deiner Nachrichten-App mit dieser App, um dir andere Perspektiven zum gleichen Thema anzusehen",
                            textAlign: TextAlign.center)),
                  ),
                ].spaced()),
          ),
          Row(
            children: [
              Expanded(
                  child: Button.integrated(
                      icon: Icons.globe2,
                      label: "website",
                      onTap: () => launchUrlString("https://robbb.in",
                          mode: LaunchMode.externalApplication))),
              Expanded(
                  child: Button.integrated(
                      icon: Icons.github,
                      label: "source",
                      onTap: () => launchUrlString(
                          "https://github.com/RobinNaumann/perspektiven",
                          mode: LaunchMode.externalApplication)))
            ],
          ),
          Padded.only(top: 1, child: const VersionInfo())
        ],
      ),
    );
  }
}

class VersionInfo extends StatefulWidget {
  const VersionInfo({super.key});

  @override
  State<VersionInfo> createState() => _VersionInfoState();
}

class _VersionInfoState extends State<VersionInfo> {
  String? version;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((value) {
      setState(() => version = "${value.version}+${value.buildNumber}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text.bodyS("${version ?? ""} | Robin 2024");
  }
}
