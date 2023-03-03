import 'package:arabian_nights_frontend/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/floors_setup_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/providers/floors_provider.dart';

class FloorsSetupScreen extends ConsumerStatefulWidget {
  const FloorsSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FloorsSetupScreen> createState() => _FloorsSetupScreenState();
}

class _FloorsSetupScreenState extends ConsumerState<FloorsSetupScreen> {
  _addFloor() async {
    try {
      var dio = Dio();
      var response = await dio.post(Constants.baseUrl + Constants.addFloorUrl);

      bool isFloorUpdated = response.data["success"];

      if (isFloorUpdated) {
        ref.read(floorsProvider.notifier).update((state) => state + 1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _minusFloor() async {
    try {
      var dio = Dio();
      var response = await dio.post(Constants.baseUrl + Constants.deleteLatestFloorUrl);


      bool isFloorUpdated = response.data["success"];

      if (isFloorUpdated) {
        ref.read(floorsProvider.notifier).update((state) => state - 1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    int floors = ref.watch(floorsProvider);
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              customAppBar(context: context, title: "floors"),
              const SizedBox(height: 20),
              for (var floor = 0; floor < floors; floor++) ...[
                ListTile(
                  leading: const Icon(Icons.apartment_rounded),
                  title:
                      Text("${getOrdinalNumber(number: floor)} Floor ($floor)"),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                const Divider(
                  indent: 30,
                  endIndent: 30,
                ),
              ],
              const SizedBox(height: 60),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addFloor();
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                ElevatedButton(
                  onPressed: () {
                    _minusFloor();
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
