import 'package:elbe/elbe.dart';
import 'package:newsy/bit/b_config.dart';
import 'package:newsy/view/v_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
