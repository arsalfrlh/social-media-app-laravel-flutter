import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmed/viewmodels/auth_viewmodel.dart';
import 'package:sosmed/viewmodels/message_viewmodel.dart';
import 'package:sosmed/viewmodels/reaction_viewmodel.dart';
import 'package:sosmed/viewmodels/post_viewmodel.dart';
import 'package:sosmed/viewmodels/user_viewmodel.dart';
import 'package:sosmed/views/auth/login_view.dart';
import 'package:sosmed/views/main/footer_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final key = await SharedPreferences.getInstance();
  final status = key.getBool("statusLogin") ?? false;
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewmodel()),
      ChangeNotifierProvider(create: (_) => PostViewmodel()),
      ChangeNotifierProvider(create: (_) => ReactionViewmodel()),
      ChangeNotifierProvider(create: (_) => MessageViewmodel()),
      ChangeNotifierProvider(create: (_) => UserViewmodel())
    ],
    child: MyApp(status: status,),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({required this.status});
  bool status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sosmed",
      home: status ? FooterView() : LoginView(),
    );
  }
}
