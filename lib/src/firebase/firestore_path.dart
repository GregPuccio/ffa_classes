class FirestorePath {
  static String fClasses() => 'classes';
  static String fClass(String classID) => 'classes/$classID';
  static String users() => 'users';
  static String user(String userID) => 'users/$userID';
  static String lessons() => 'lessons';
  static String lesson(String lessonID) => 'lessons/$lessonID';

  static String feedbacks() => 'feedback';
  static String feedback(String feedbackID) => 'feedback/$feedbackID';
}
