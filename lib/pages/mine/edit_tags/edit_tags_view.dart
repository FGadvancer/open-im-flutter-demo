import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'edit_tags_logic.dart';

class EditTagsPage extends StatelessWidget {
  final logic = Get.find<EditTagsLogic>();
  EditTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.tags,
        right: StrRes.save.toText
          ..style = Styles.ts_0C1C33_17sp
          ..onTap = logic.save,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: logic.tags.map((tag) => GestureDetector(
                onTap: () {}, // 保留交互行为，或根据需求修改
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 设置内边距
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // 统一背景色
                    borderRadius: BorderRadius.circular(12), // 统一圆角
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 让子元素自适应大小
                    children: [
                      Text(
                        tag,
                        style: TextStyle(fontSize: 14, color: Styles.c_0C1C33), // 统一字体样式
                      ),
                      SizedBox(width: 4), // 间距
                      GestureDetector(
                        onTap: () => logic.removeTag(tag), // 触发删除操作
                        child: Icon(Icons.close, size: 16, color: Colors.black54), // 统一删除按钮样式
                      ),
                    ],
                  ),
                ),
              )).toList(),
            )),
            TextField(
              focusNode: logic.focusNode,
              controller: logic.controller,
              decoration: InputDecoration(
                hintText: StrRes.tagsInputHint,
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => logic.addTag(logic.controller.text),
                ),
              ),
              onSubmitted: logic.addTag,
            ),
          ],
        ),
      ),
    );
  }
}
