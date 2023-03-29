
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;


class NotificationService {
  static bool isNotifAllowed = false;
  void init() async {
    await AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: const Color(0xffFF0000),
              ledColor: Colors.white,


              channelShowBadge: true),
        ]);
// get premision from user 
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      isNotifAllowed = isAllowed;
      if (!isAllowed) {
        AlertDialog(
          title: Text('السماح بالاشعارات'),
          content: const Text('لتلقي الإشعارات  يجب الموافقة على منح التطبيق إذونات الإشعارات'),
          actions: [
            ElevatedButton(
                onPressed: () async {

                  await AwesomeNotifications()
                      .requestPermissionToSendNotifications();
                },
                child: const Text('موافق')),
             ElevatedButton(
                onPressed: () {

                },
                child: const Text('غير موافق')),
          ],

        );
      }
    });
    
  }

  //Handle create notification in channel
  Future<void> createAlertNotifications(title,body) async {

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'basic_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,

    ));
  }

  //generate unique id for notification
  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(1000);
  }

  Future<void> sendNotification(title,message,List to)async{
    Dio _dio= Dio();
    var notification={
      "to" : "/topics/all",
      // "notification" : {
      //   "body" : "New Update Available",
      //   "title" : "Update",
      // },
      "data":{
        "to_user":to,
        "body":message,
        "title":title
      }
    };
    _dio.options.headers["authorization"] = "key=AAAAlERDexE:APA91bFvqvRwvl_OOnXvaig97xMbVg0dDr_yZizPRRE_KMXXkXCEapLxeNr352bEawQkEZAY7AXUgDkeHGdXyHqcbTex50JQFGBkjybMpX7si1Nr7nN5OE9FIZxqqAsg80BpBX5S6Fqr";
    await _dio.post("https://fcm.googleapis.com/fcm/send",
        data: notification)
        .then((value) => print("send done"))
        .catchError((e){
      print(e);
    });
  }
}
