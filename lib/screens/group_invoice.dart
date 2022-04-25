import 'package:flutter/material.dart';
import 'package:hatarakujikan_web/helpers/functions.dart';
import 'package:hatarakujikan_web/models/group.dart';
import 'package:hatarakujikan_web/providers/group.dart';
import 'package:hatarakujikan_web/providers/group_invoice.dart';
import 'package:hatarakujikan_web/widgets/admin_header.dart';
import 'package:hatarakujikan_web/widgets/custom_admin_scaffold.dart';
import 'package:hatarakujikan_web/widgets/text_icon_button.dart';
import 'package:provider/provider.dart';

class GroupInvoiceScreen extends StatelessWidget {
  static const String id = 'group_invoice';

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groupInvoiceProvider = Provider.of<GroupInvoiceProvider>(context);
    GroupModel? group = groupProvider.group;

    return CustomAdminScaffold(
      groupProvider: groupProvider,
      selectedRoute: id,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeader(
            title: '請求書の管理',
            message: '本システムの利用に当たって発生する請求書の控えを表示しています。',
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextIconButton(
                iconData: Icons.today,
                iconColor: Colors.white,
                label: dateText('yyyy年MM月', groupInvoiceProvider.month),
                labelColor: Colors.white,
                backgroundColor: Colors.lightBlueAccent,
                onPressed: () async {
                  DateTime? selected = await customMonthPicker(
                    context: context,
                    init: groupInvoiceProvider.month,
                  );
                  if (selected == null) return;
                  groupInvoiceProvider.changeMonth(selected);
                },
              ),
              Container(),
            ],
          ),
          SizedBox(height: 8.0),
          Expanded(child: Text('現在利用できません。'))
        ],
      ),
    );
  }
}
