
import 'package:arabian_nights_frontend/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/kitchen_app/screens/kitchen_app.dart';
import 'package:arabian_nights_frontend/app/pos/screens/order_booking_screen.dart';
import 'package:arabian_nights_frontend/app/pos/widgets/custom_icon_button.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/menu_controller.dart';
import 'package:arabian_nights_frontend/app/settings/settings_screen.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/constants/roles.dart';
import 'package:arabian_nights_frontend/packages/shimmer.dart';
import 'package:arabian_nights_frontend/providers/floors_provider.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';
import 'package:arabian_nights_frontend/providers/tables_provider.dart';
import 'package:arabian_nights_frontend/providers/user_provider.dart';

class POSHomeScreen extends ConsumerStatefulWidget {

  const POSHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<POSHomeScreen> createState() => _POSHomeScreenState();
}

class _POSHomeScreenState extends ConsumerState<POSHomeScreen> {
  int _currentFloor = 0;

  bool _isLoading = true;

  @override
  void initState() {
    _getFloorsAndTables();
    _getMenu();
    super.initState();
  }

  _getFloorsAndTables() async {
    try {
      var dio = Dio();
     var floorResponse = await dio.get(Constants.baseUrl + Constants.getFloorsUrl);

      var totalFloorResponse = await dio.get(Constants.baseUrl + Constants.getTotalFloors);
      num totalFloors =  totalFloorResponse.data["numFloors"];
      List<dynamic> totalTables = [];
      for (int i = 0; i < floorResponse.data["floors"].length.toInt(); i++) {
        Map<String, dynamic> curr = {
          "floor" : floorResponse.data["floors"][i]["floorNum"],
          "tables" : floorResponse.data["floors"][i]["numTables"]
        };
        totalTables.add(curr);
      }

      ref.read(floorsProvider.notifier).state = totalFloors.toInt();
      ref.read(tablesProvider.notifier).state = totalTables;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _getMenu() async {

    var dio = Dio();
    var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
    //List<QueryDocumentSnapshot>? menuCategories = await getMenuCategories();
    List<dynamic> menu = [];
    List<dynamic> items;
    for (int i = 0; i < menuResponse.data["categories"].length; i++) {
      var category = menuResponse.data["categories"][i]["categoryName"];

      items = [];
      for (int j = 0; j < menuResponse.data["categories"][i]["items"].length; j++) {

        Map<String, dynamic> curr = {
          "itemName" : menuResponse.data["categories"][i]["items"][j]["name"],
          "itemPrice" : menuResponse.data["categories"][i]["items"][j]["price"],
          "itemImage" : menuResponse.data["categories"][i]["items"][j]["picUrl"],
        };
        items.add(curr);
      }
      Map<String, dynamic> curr = {
        "category" : category,
        "items" : items
      };
      menu.add(curr);
    }

    ref.read(menuProvider.notifier).state = menu;
  }


  _showFloorSelectionBottomSheet() {
    int floors = ref.watch(floorsProvider);

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(44),
          topRight: Radius.circular(44),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (dragScrollSheetContext, scrollController) {
            return ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 30),
                for (var floor = 0; floor < floors; floor++) ...[
                  ListTile(
                    leading: const Icon(Icons.apartment_rounded),
                    title: Text(
                        "${getOrdinalNumber(number: floor)} Floor ($floor)"),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                    onTap: () {
                      // num currentFloorTables = 0;
                      // dynamic currentFloorItem = allTables.singleWhere(
                      //     (element) => element["floor"] == floor,
                      //     orElse: () => -1);

                      // if (currentFloorItem != -1) {
                      //   currentFloorTables = currentFloorItem["tables"] ?? 0;
                      // }

                      setState(() {
                        _currentFloor = floor;
                        // tables = currentFloorTables;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(
                    indent: 30,
                    endIndent: 30,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int gridCount = size.width > 1000
        ? 4
        : size.width > 500
            ? 3
            : 2;

    UserModel userModel = ref.watch(userProvider);
    // int floors = ref.watch(floorsProvider);
    List<dynamic> totalTables = ref.watch(tablesProvider);

    int indexOfCurrentFloorTables =
        totalTables.indexWhere((element) => element["floor"] == _currentFloor);
    num tablesOnCurrentFloor = 0;
    if (indexOfCurrentFloorTables != -1) {
      tablesOnCurrentFloor =
          totalTables[indexOfCurrentFloorTables]["tables"] ?? 0;
    }

    // role: user
    if (userModel.role == UserRoles.user.name) {
      return const Scaffold(
        body: Center(
          child: Text("You don't have access to POS"),
        ),
      );
    }

    // role: kitchen
    if (userModel.role == UserRoles.kitchen.name) {
      return const KitchenApp();
    }

    // role: manager, recieptionist, waiterOrWaitress
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: Image(
          image: const AssetImage("assets/images/logo/logo.png"),
          width: size.width > 400 ? 300 : size.width * .8,
        ),
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          child: ElevatedButton.icon(
            onPressed: () {
              _showFloorSelectionBottomSheet();
            },
            icon: const Icon(Icons.apartment_rounded),
            label: Text(
                "${getOrdinalNumber(number: _currentFloor, short: true)}F"),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(0),
              ),
              backgroundColor:
                  MaterialStateProperty.all(const Color(0xFFF8F8F8)),
              foregroundColor:
                  MaterialStateProperty.all(const Color(0xFF797979)),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: CustomIconButton(
              icon: Icons.settings_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // body: Center(
      //     child: Text(
      //         "Home Screen POS\nRole: ${userModel.role}\nFloors: $floors")),

      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image:
                AssetImage("assets/images/splash_screen/splash_screen_bg.png"),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: _isLoading
            ? _skeleton()
            : tablesOnCurrentFloor > 0
                ? GridView.count(
                    crossAxisCount: gridCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      for (num table = 1;
                          table <= tablesOnCurrentFloor;
                          table++) ...[
                        Material(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).backgroundColor,
                          child: Ink(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderBookingScreen(
                                      floor: _currentFloor,
                                      table: table,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFFDCDCDC),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: const Color(0xFF4CAF50),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Table $table",
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : const Center(
                    child: Text("No Tables found on this Floor."),
                  ),
      ),
    );
  }

  Widget _skeleton() {
    Size size = MediaQuery.of(context).size;
    int gridCount = size.width > 1000
        ? 4
        : size.width > 500
            ? 3
            : 2;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFF2F2F2),
      highlightColor: Colors.white,
      child: GridView.count(
        crossAxisCount: gridCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: List.generate(
          10,
          (index) => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: const Color(0xFFF2F2F2),
            ),
          ),
        ),
      ),
    );
  }
}
