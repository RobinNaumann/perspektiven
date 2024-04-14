import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';
import 'package:newsy/bit/b_config.dart';
import 'package:newsy/view/v_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String version = "unknown";
  try {
    final pInfo = await PackageInfo.fromPlatform();
    version = "${pInfo.version}+${pInfo.buildNumber}";
  } catch (e) {
    //
  }

  // setup Moewe for crash logging
  Moewe(
      host: "moewe.robbb.in",
      project: "0d0f49eaf6318720",
      appId: "1hdk97r39kdk2ifk",
      appVersion: version);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BitProvider(
        create: (_) => ConfigBit(),
        child: ConfigBit.builder(
          onData: (bit, data) => ElbeApp(
              mode: data.dark ? ColorModes.dark : ColorModes.light,
              router: router,
              theme: ThemeData.preset(
                color: Colors.blue,
              )),
        ));
  }
}

class ThemeToggleBtn extends StatelessWidget {
  const ThemeToggleBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigBit.builder(
        onData: (bit, data) => IconButton.integrated(
              icon: data.dark ? Icons.sun : Icons.moon,
              onTap: () => bit.emit(Config(dark: !data.dark)),
            ));
  }
}
