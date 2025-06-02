import 'package:flutter/material.dart';
import 'package:pagination/service/apiPetani.dart';
import 'package:pagination/pages/admin.dart';
import 'package:pagination/pages/petaniPages.dart';
import 'package:pagination/pages/loginPage.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Apipetani.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.data == true) {
            return FutureBuilder(
              future: Apipetani.getUserType(),
              builder: (context, snapshotType) {
                if (snapshotType.data == 'admin') return AdminHome();
                return PetaniPage();
              },
            );
          } else {
            return LoginPage();
          }
        }
      },
    );
  }
}
