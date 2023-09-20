import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_comunidad/loading.dart';
import 'package:mi_comunidad/pages/communities/communities.dart';
import 'package:mi_comunidad/pages/my_account.dart';
import 'package:mi_comunidad/models/newuser.dart';
import 'package:mi_comunidad/services/auth.dart';
import 'package:mi_comunidad/pages/wrapper.dart';
import 'package:mi_comunidad/shared/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mi_comunidad/pages/authenticate/register2.dart';

// rounded appbar: https://flutteragency.com/how-to-set-rounded-bottom-on-appbar-in-flutter/
// rounded corner container: https://stackoverflow.com/questions/57777737/flutter-give-container-rounded-border
// container's shadow: https://stackoverflow.com/questions/52227846/how-can-i-add-shadow-to-the-widget-in-flutter







void main() async {
  runApp(MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es', 'ES')],
      initialRoute: '/',
      routes: {
        '/': (context) => const Loading(),
        '/register2': (context) => const Register2(),
        '/miperfil': (context) => StreamProvider<NewUser?>.value(
            initialData: null,
            value: AuthService().user,
            child: const MyAccount()),
        '/wrapper': (context) => StreamProvider<NewUser?>.value(
            initialData: null,
            value: AuthService().user,
            child: const Wrapper()),
        '/communities': (context) => StreamProvider<NewUser?>.value(
            initialData: null,
            value: AuthService().user,
            child: const Communities()),
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<NewUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        themeMode: ThemeMode.system,
        theme: Themes.lightTheme,
        darkTheme: Themes.darkTheme,
        home: const Wrapper(),
      ),
    );
  }
}
