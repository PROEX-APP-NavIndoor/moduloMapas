import 'package:flutter/material.dart';
import 'package:mvp_proex/app/app.color.dart';
import 'package:mvp_proex/features/login/login.view.dart';
import 'package:mvp_proex/features/map/map.view.dart';
import 'package:mvp_proex/features/mapselection/mapselection.view.dart';
import 'package:mvp_proex/features/user/user.model.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => UserModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MVP Demo',
        theme: ThemeData(
          primarySwatch: AppColors.primary as MaterialColor,
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/login',
        routes: {
          '/map': (context) => const MapView(),
          '/login': (context) => const LoginView(),
          '/mapselection':(context) => const MapselectionView(),
        },
      ),
    );
  }
}
