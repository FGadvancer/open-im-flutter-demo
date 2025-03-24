import 'package:get/get.dart';

import 'edit_tags_logic.dart';


class EditTagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditTagsLogic());
  }
}

