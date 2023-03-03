import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/tables_setup_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/get_ordinal_number.dart';
import 'package:arabian_nights_frontend/config/theme.dart';
import 'package:arabian_nights_frontend/packages/animated_number_counter.dart';
import 'package:arabian_nights_frontend/providers/floors_provider.dart';
import 'package:arabian_nights_frontend/providers/tables_provider.dart';

class TablesSetupScreen extends ConsumerStatefulWidget {
  const TablesSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TablesSetupScreen> createState() => _TablesSetupScreenState();
}

class _TablesSetupScreenState extends ConsumerState<TablesSetupScreen> {
  num tables = 0;
  int currentFloor = 0;

  bool _isSaving = false;
  List<dynamic> allTables = [];

  @override
  void initState() {
    super.initState();
    _getTotalTablesOnFloor();
  }

  _getTotalTablesOnFloor() {
    try {
      List<dynamic> totalTables = ref.read(tablesProvider);
      dynamic currentFloorItem = totalTables.singleWhere(
          (element) => element["floor"] == currentFloor,
          orElse: () => -1);
      num currentFloorTables = 0;
      if (currentFloorItem != -1) {
        currentFloorTables = currentFloorItem["tables"] ?? 0;
      }
      setState(() {
        tables = currentFloorTables;
        allTables = totalTables;
      });
    } catch (e) {
      debugPrint("No tables available in DB");
    }
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
                      num currentFloorTables = 0;
                      dynamic currentFloorItem = allTables.singleWhere(
                          (element) => element["floor"] == floor,
                          orElse: () => -1);

                      if (currentFloorItem != -1) {
                        currentFloorTables = currentFloorItem["tables"] ?? 0;
                      }

                      setState(() {
                        currentFloor = floor;
                        tables = currentFloorTables;
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

  _addTablesToFloor() {
    int currentFloorIndex =
        allTables.indexWhere((element) => element["floor"] == currentFloor);

    if (currentFloorIndex != -1) {
      num newTables = tables + 1;

      setState(() {
        tables = newTables;
        allTables[currentFloorIndex] = {
          "floor": currentFloor,
          "tables": newTables
        };
      });
    } else {
      num newTables = tables + 1;

      setState(() {
        tables = newTables;
        allTables.add({"floor": currentFloor, "tables": tables});
      });
    }
  }

  _minusTablesToFloor() {
    int currentFloorIndex =
        allTables.indexWhere((element) => element["floor"] == currentFloor);

    if (currentFloorIndex != -1) {
      num newTables = tables - 1;

      setState(() {
        tables = newTables;
        allTables[currentFloorIndex] = {
          "floor": currentFloor,
          "tables": newTables
        };
      });
    } else {
      num newTables = tables - 1;

      setState(() {
        tables = newTables;
        allTables.add({"floor": currentFloor, "tables": tables});
      });
    }
  }

  _saveChanges() async {
    try {
      setState(() {
        _isSaving = true;
      });
      int curIndex = allTables.indexWhere((element) => element["floor"] == currentFloor);
      await updateTotalTables(tables: allTables, index: curIndex);
      ref.read(tablesProvider.notifier).state = allTables;
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              customAppBar(context: context, title: "tables"),
              Column(
                children: [
                  Text("${getOrdinalNumber(number: currentFloor)} Floor"),
                  tablesCounter(),
                  const Text("Tables"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _isSaving ? null : _showFloorSelectionBottomSheet,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey[300]!;
                        }
                        return const Color(0xFFFA1E0E).withOpacity(.1);
                      }),
                      foregroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey;
                        }
                        return const Color(0xFFFA1E0E);
                      }),
                      overlayColor: MaterialStateProperty.all(
                          const Color(0xFFFA1E0E).withOpacity(.5)),
                    ),
                    icon: const Icon(Icons.apartment_rounded),
                    label:
                        Text("${getOrdinalNumber(number: currentFloor)} Floor"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey[300]!;
                        }
                        return const Color(0xFFFA1E0E).withOpacity(.1);
                      }),
                      foregroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey;
                        }
                        return const Color(0xFFFA1E0E);
                      }),
                      overlayColor: MaterialStateProperty.all(
                          const Color(0xFFFA1E0E).withOpacity(.5)),
                    ),
                    icon: const Icon(Icons.done_rounded),
                    label: const Text("save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tablesCounter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _addTablesToFloor();
            },
            icon: const Icon(Icons.add_rounded),
          ),
          AnimatedNumberCounter(
            value: tables,
            textStyle: const TextStyle(
              color: customPalette,
              fontWeight: FontWeight.w900,
              fontSize: 96,
            ),
          ),
          IconButton(
            onPressed: () {
              _minusTablesToFloor();
            },
            icon: const Icon(Icons.remove_rounded),
          ),
        ],
      ),
    );
  }
}
