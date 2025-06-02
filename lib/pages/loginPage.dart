import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pagination/service/apiPetani.dart';
import 'package:pagination/pages/admin.dart';
import 'package:pagination/pages/petaniPages.dart';

class LoginPage extends StatelessWidget {
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    final result = await Apipetani.login(
      email: data.name,
      password: data.password,
      deviceName: 'android',
    );

    if (result['success'] == true) {
      return null; // success
    } else {
      return result['message'] ?? 'Login failed';
    }
  }

  Future<String?> _signupUser(SignupData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) async {
    return 'Fitur belum tersedia';
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login WEFGIS',
      onLogin: _authUser,
      onSignup: _signupUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () async {
        final type = await Apipetani.getUserType();
        if (type == 'admin') {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => AdminHome()));
        } else {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => PetaniPage()));
        }
      },
    );
  }
}
