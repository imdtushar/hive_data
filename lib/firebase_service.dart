import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

// @pragma('vm:entry-point')
// int setNotificationId(String type) {
//   switch (type) {
//     case 'Chats':
//       return 2;
//     case 'Followers':
//       return 3;
//     case 'Likes':
//       return 4;
//     case 'Comments':
//       return 5;
//     case 'Follow Requests':
//       return 6;
//     case 'General Notifications':
//       return 7;
//     default:
//       return 1;
//   }
// }

Future<void> initializeFirebaseService() async {
  await Firebase.initializeApp();

  var messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  final fCMToken = await messaging.getToken();
  log(fCMToken.toString());
  var notificationService = NotificationService();

  if (!notificationService.isInitialized) {
    await notificationService.initialize();
  }

  FirebaseMessaging.onBackgroundMessage(onHandleBackgroundMessage);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.data.isNotEmpty) {
      var messageData = message.data;
      var type = messageData['type'];

      var title = messageData['title'];
      var body = messageData['body'];
      var imageUrl = messageData['image'];


      // if (type == "message") {
      //   title = messageData['senderName'];
      //   body = messageData['content'];
      // }

      notificationService.showNotification(

        title: title ?? '',
        body: body ?? '',
        priority: true,
        // id: setNotificationId(type),
        largeIcon: imageUrl,
        channelId: type ?? 'General Notifications',
        channelName: type ?? 'General notifications',
      );
    }

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
    }
  });
}

Future<void> onHandleBackgroundMessage(RemoteMessage message) async {
  var notificationService = NotificationService();

  if (!notificationService.isInitialized) {
    await notificationService.initialize();
  }

  if (message.data.isNotEmpty) {
    log('Message data: ${message.data}');
    var messageData = message.data;

    var title = messageData['title'];
    var body = messageData['body'];
    var imageUrl = messageData['image'];
    var type = messageData['type'];

    // if (type == "message") {
    //   title = messageData['senderName'];
    //   body = messageData['content'];
    // }

    notificationService.showNotification(

      title: title ?? '',
      body: body ?? '',
      priority: true,
      // id: setNotificationId(type),
      largeIcon: imageUrl,
      channelId: type ?? 'General Notifications',
      channelName: type ?? 'General notifications',
    );
  }

  if (message.notification != null) {
    log('Message also contained a notification: ${message.notification}');
  }
}
