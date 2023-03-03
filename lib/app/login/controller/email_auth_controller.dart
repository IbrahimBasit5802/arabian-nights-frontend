import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
Future<User?> signUpUserWithEmail(
    {required String email,
    required String password,
    required String name}) async {
  try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    User? user = userCredential.user;
    await user!.updateDisplayName(name);
    return user;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "email-already-in-use":
        throw Exception("email already registered with app.");
      case "invalid-email":
        throw Exception("Invalid email provided.");
      case "operation-not-allowed":
        throw Exception("Operation denied");
      case "weak-password":
        throw Exception("Password is weak, provide strong password.");
      default:
        throw Exception(
            "Something went wrong while signup process. Try again after sometime.");
    }
  }
}

Future<void> sendPasswordResetLink({required String email}) async {
  try {
    await auth.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "user-not-found":
        throw Exception(
            "The email you provided is not registered, please provide correct email.");
      case "invalid-email":
        throw Exception("Invalid email provided.");
      case "operation-not-allowed":
        throw Exception("Operation denied");
      case "weak-password":
        throw Exception("Password is weak, provide strong password.");
      default:
        throw Exception(
            "Something went wrong in process. Try again after sometime.");
    }
  }
}

Future<User?> signInWithEmail(
    {required String email, required String password}) async {
  try {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "user-not-found":
        throw Exception(
            "The email you provided is not registered, please provide correct email.");
      case "invalid-email":
        throw Exception("Invalid email provided.");
      case "user-disabled":
        throw Exception("Operation denied");
      case "wrong-password":
        throw Exception("Email or Password is wrong.");
      default:
        throw Exception(
            "Something went wrong while signin process. Try again after sometime.");
    }
  }
}
