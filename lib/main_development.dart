import 'package:rag/app/app.dart';
import 'package:rag/bootstrap.dart';
import 'package:rag/firebase_options_dev.dart';

Future<void> main() async {
  await bootstrap(
    () => const App(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
