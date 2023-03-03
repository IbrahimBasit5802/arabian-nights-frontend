import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//final menuProvider = StateProvider<List<QueryDocumentSnapshot>>((ref) => []);
final menuProvider = StateProvider<List>((ref) => []);