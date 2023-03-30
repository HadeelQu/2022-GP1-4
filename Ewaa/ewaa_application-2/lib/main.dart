import 'package:ewaa_application/notification_service.dart';
import 'package:ewaa_application/screens/addP.dart';
import 'package:ewaa_application/screens/continuesAdd.dart';
import 'package:ewaa_application/screens/edit_profile.dart';
import 'package:ewaa_application/screens/favouritesPage.dart';
import 'package:ewaa_application/screens/forget_passward.dart';
import 'package:ewaa_application/screens/home.dart';
import 'package:ewaa_application/screens/listPets.dart';
import 'package:ewaa_application/screens/login.dart';
import 'package:ewaa_application/screens/my_requests.dart';
import 'package:ewaa_application/screens/notifications_screen.dart';

import 'package:ewaa_application/screens/profile.dart';
import 'package:ewaa_application/screens/register.dart';
import 'package:ewaa_application/screens/search.dart';
import 'package:ewaa_application/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/adoption_form.dart';
import 'screens/my_pets_screen.dart';
import 'screens/requests_log.dart';
import 'screens/history.dart';

var fcm = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.length == 0) await Firebase.initializeApp();
  var _auth = FirebaseAuth.instance;
  if (_auth.currentUser == null) return;
  var data = message.data;
  var to_user = data["to_user"];
  print(to_user);
  var body = data["body"];
  var title = data["title"];
  if (to_user.contains(_auth.currentUser!.uid)) {
    NotificationService().createAlertNotifications(title, body);
  }

  print("Handling a background message: ${message.messageId}-${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    var _auth = FirebaseAuth.instance;
    if (_auth.currentUser == null) return;
    var data = message.data;
    var to_user = data["to_user"];
    print(to_user);
    var body = data["body"];
    var title = data["title"];
    if (to_user.contains(_auth.currentUser!.uid)) {
      NotificationService().createAlertNotifications(title, body);
    }
  });
  fcm.getInitialMessage().then(
      (value) => value != null ? _firebaseMessagingBackgroundHandler : false);

  await fcm.subscribeToTopic("all");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', ''), // English, no country code
      ],
      title: 'ايواء',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ElMessiri',
        textTheme: ThemeData.light().textTheme.copyWith(
              // يساعد اغير الستايل الديفولت
              headline5: TextStyle(
                color: Style.brown,
                fontSize: 60,
                fontFamily: 'ElMessiri',
              ),
              headline6: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
              ),
              headline1: TextStyle(
                color: Style.brown,
                fontSize: 23,
                fontFamily: 'ElMessiri',
              ),
              headline2: TextStyle(
                color: Style.brown,
                fontSize: 50,
                fontFamily: 'ElMessiri',
              ),
              headline3: TextStyle(
                color: Style.black,
                fontSize: 15,
                fontFamily: 'ElMessiri',
                fontWeight: FontWeight.bold,
              ),
              headline4: TextStyle(
                color: Style.purpole,
                fontSize: 26,
                fontFamily: 'ElMessiri',
              ),
            ),
      ),
      // احدد موديل الخط

      home: HomePage(),
      routes: {
        Register.screenRoute: (context) => Register(),
        Login.screenRoute: (context) => Login(),
        HomePage.screenRoute: (context) => HomePage(),
        ProfilePage.screenRoute: (context) => ProfilePage(),
        ListPetsPage.screenRoute: (context) => ListPetsPage(),
        ContinuesAdd.screenRoute: (context) => ContinuesAdd(),
        AddPets.screenRoute: (context) => AddPets(),
        ForgfetPassward.screenRoute: (context) => ForgfetPassward(),
        MyPetsPage.screenRoute: (context) => MyPetsPage(),
        SearchPage.screenRoute: (context) => SearchPage(),
        FavouritesPage.screenRoute: (context) => FavouritesPage(),
        EditProfilePage.screenRoute: (context) => EditProfilePage(),
        MyRequests.screenRoute: (context) => MyRequests(),
        RequestsLog.screenRoute: (context) => RequestsLog(),
        AdoptionForm.screenRoute: (context) => AdoptionForm(),
        NotificationsScreen.screenRoute: (context) => NotificationsScreen(),
        History.screenRoute: (context) => History(),
      },
    );
  }
}
