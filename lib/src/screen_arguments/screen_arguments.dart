import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';

class ScreenArgs {
  final FClass? fClass;
  final Lesson? lesson;
  final UserData? userData;
  ScreenArgs({
    this.fClass,
    this.lesson,
    this.userData,
  });
}
