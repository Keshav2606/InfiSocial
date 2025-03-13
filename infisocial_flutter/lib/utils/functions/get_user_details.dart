import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getUserDetails(String userId) async {
  var snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (snapshot.data() != null) {
    return snapshot.data()!;
  } else {
    return {};
  }
}
