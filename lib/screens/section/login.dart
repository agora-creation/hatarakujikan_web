import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/helpers/style.dart';
import 'package:hatarakujikan_web/providers/section.dart';
import 'package:hatarakujikan_web/screens/login.dart';
import 'package:hatarakujikan_web/screens/section/select.dart';
import 'package:hatarakujikan_web/widgets/custom_link_button.dart';
import 'package:hatarakujikan_web/widgets/custom_text_form_field.dart';
import 'package:hatarakujikan_web/widgets/error_dialog.dart';
import 'package:hatarakujikan_web/widgets/loading.dart';
import 'package:hatarakujikan_web/widgets/round_background_button.dart';
import 'package:provider/provider.dart';

class SectionLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sectionProvider = Provider.of<SectionProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: kLoginDecoration,
          child: sectionProvider.status == SectionStatus.Authenticating
              ? Loading(color: Colors.white)
              : Column(
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
                        SizedBox(height: 8.0),
                        Text(
                          '部署/事業所の管理者専用',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    Container(
                      width: 350.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextFormField(
                            controller: sectionProvider.email,
                            obscureText: false,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            label: 'メールアドレス',
                            color: Colors.white,
                            prefix: Icons.email,
                            suffix: null,
                            onTap: null,
                          ),
                          SizedBox(height: 16.0),
                          CustomTextFormField(
                            controller: sectionProvider.password,
                            obscureText: true,
                            textInputType: null,
                            maxLines: 1,
                            label: 'パスワード',
                            color: Colors.white,
                            prefix: Icons.lock,
                            suffix: null,
                            onTap: null,
                          ),
                          SizedBox(height: 24.0),
                          RoundBackgroundButton(
                            onPressed: () async {
                              if (!await sectionProvider.signIn()) {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => ErrorDialog(
                                    'ログインに失敗しました。メールアドレスもしくはパスワードが間違っている可能性があります。',
                                  ),
                                );
                                return;
                              }
                              sectionProvider.clearController();
                              overlayScreen(
                                context,
                                SectionSelectScreen(
                                  sectionProvider: sectionProvider,
                                ),
                              );
                            },
                            label: 'ログイン',
                            color: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.0),
                    Center(
                      child: CustomLinkButton(
                        onTap: () {
                          nextScreen(context, LoginScreen());
                        },
                        label: '会社/組織の管理者はここをクリック',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
