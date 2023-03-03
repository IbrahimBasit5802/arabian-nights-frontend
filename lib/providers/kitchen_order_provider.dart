import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/kitchen_app/controllers/kitchen_orders_controller.dart';

final StreamProvider<QuerySnapshot> kitchenOrdersProvider =
    StreamProvider<QuerySnapshot>(
  (ref) => getKitcherOrdersStream(),
);
