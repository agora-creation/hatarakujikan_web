import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field.dart';
import 'package:hatarakujikan_web/widgets/round_background_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFb74D),
                Color(0xFFFF9800),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('はたらくじかん', style: kTitleTextStyle),
                  Text('for WEB', style: kSubTitleTextStyle),
                ],
              ),
              SizedBox(height: 24.0),
              Container(
                width: 350.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextFormField(
                      controller: null,
                      obscureText: false,
                      textInputType: TextInputType.emailAddress,
                      maxLines: 1,
                      labelText: 'メールアドレス',
                      labelColor: Colors.white,
                      prefixIconData: Icons.email,
                      suffixIconData: null,
                      onTap: null,
                    ),
                    SizedBox(height: 16.0),
                    CustomTextFormField(
                      controller: null,
                      obscureText: true,
                      textInputType: null,
                      maxLines: 1,
                      labelText: 'パスワード',
                      labelColor: Colors.white,
                      prefixIconData: Icons.lock,
                      suffixIconData: null,
                      onTap: null,
                    ),
                    SizedBox(height: 24.0),
                    RoundBackgroundButton(
                      labelText: 'ログイン',
                      labelColor: Colors.white,
                      backgroundColor: Colors.blue,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
