import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arabian_nights_frontend/app/settings/controllers/menu_controller.dart';
import 'package:arabian_nights_frontend/app/settings/widgets/custom_app_bar.dart';
import 'package:arabian_nights_frontend/common/alert_dialog.dart';
import 'package:arabian_nights_frontend/config/app.dart';
import 'package:arabian_nights_frontend/providers/menu_provider.dart';

import '../../../constants.dart';

class MenuItemUpdateScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String itemName;
  final String oldItemName;
  final num itemPrice;
  final dynamic menuItem;
  final List<dynamic> menuItems;

  const MenuItemUpdateScreen({
    Key? key,
    required this.oldItemName,
    required this.itemName,
    required this.itemPrice,
    required this.menuItem,
    required this.menuItems,
    required this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<MenuItemUpdateScreen> createState() =>
      _MenuItemAddScreenState();
}

class _MenuItemAddScreenState extends ConsumerState<MenuItemUpdateScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemImageUrlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _imageFile;
  bool _isBtnTapped = false;

  @override
  void initState() {
    _itemNameController.text = widget.itemName;
    _itemPriceController.text = widget.itemPrice.toString();

    super.initState();
  }

  _deleteMenuItem() async {
    setState(() {
      _isBtnTapped = true;
    });

    try {

      var dio = Dio();
      //  update state provider for menu
      await dio.post(Constants.baseUrl + Constants.deleteItemUrl, data: {
        "categoryName" : widget.categoryId,
        "name" : widget.itemName,
      });
      var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
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


      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
      showAlertDialog(
        context: context,
        title: "Oops!",
        description: "Something went wrong while removing item.",
      );
    }

    setState(() {
      _isBtnTapped = false;
    });
  }

  _updateMenuItem() async {
    setState(() {
      _isBtnTapped = true;
    });
    try {
      String itemName = _itemNameController.text;
      num itemPrice = num.tryParse(_itemPriceController.text) ?? 0;
      String imageURL = _itemImageUrlController.text;
      if (itemName.isNotEmpty) {
        // upload image

        if (imageURL != null) {
          // add to collection document.


          var dio = Dio();

          await dio.post(Constants.baseUrl + Constants.updateItemUrl, data: {
            "categoryName": widget.categoryId,
            "name": itemName,
            "price": itemPrice,
            "picUrl": imageURL,
            "oldName": widget.oldItemName,
          });
          var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
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

          if (menu != null) {
            ref.read(menuProvider.notifier).state = menu;
          }

          if (!mounted) return;
          Navigator.pop(context);
        } else {
          var dio = Dio();
          await dio.post(Constants.baseUrl + Constants.updateItemUrl, data: {
            "categoryName": widget.categoryId,
            "name": itemName,
            "price": itemPrice,
            "picUrl": imageURL,
            "oldName": widget.oldItemName,
          });
          //  update state provider for menu
          var menuResponse = await dio.get(Constants.baseUrl + Constants.getCategoriesUrl);
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
          if (menu != null) {
            ref.read(menuProvider.notifier).state = menu;
          }
          if (!mounted) return;
          Navigator.pop(context);
        }
      } else {
        showAlertDialog(
          context: context,
          title: "Oops!",
          description: "Provide item name.",
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      showAlertDialog(
        context: context,
        title: "oops!",
        description: "Something went wrong while updating item.",
      );
    }
    setState(() {
      _isBtnTapped = false;
    });
  }

  _pickImageFromCamera() async {
    XFile? file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 70,
        maxHeight: 1080,
        maxWidth: 1080,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
  }

  _pickImageFromDevice() async {
    XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 70,
        maxHeight: 1080,
        maxWidth: 1080,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          customAppBar(context: context, title: "menu update item"),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          Column(
            children: [
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("Item Name"),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _itemNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item name here...",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("Item Price"),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _itemPriceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item price here...",
                    prefixText: appCurrencySymbol,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text("Item Image Url (optional)"),
              ),
              const SizedBox(height: 8),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _itemImageUrlController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item Url here...",
                    prefixText: appCurrencySymbol,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 30),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: _isBtnTapped ? null : _updateMenuItem,
                  child: Text(_isBtnTapped ? "Please wait..." : "Update item"),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: size.width > 400 ? 400 : size.width,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextButton(
                  onPressed: _isBtnTapped ? null : _deleteMenuItem,
                  child: Text(_isBtnTapped ? "Please wait..." : "Delete item"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
  //
  // _showImageSelection() {
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: true,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(44)),
  //     builder: (ctx) {
  //       return Container(
  //         height: 200,
  //         padding: const EdgeInsets.symmetric(horizontal: 30),
  //         alignment: Alignment.center,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             ListTile(
  //               title: const Text("Take picture from Camera"),
  //               leading: const Icon(Icons.camera_alt_rounded),
  //               onTap: () {
  //                 _pickImageFromCamera();
  //                 Navigator.pop(ctx);
  //               },
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12)),
  //             ),
  //             ListTile(
  //               title: const Text("Select picture from device"),
  //               leading: const Icon(Icons.image_rounded),
  //               onTap: () {
  //                 _pickImageFromDevice();
  //                 Navigator.pop(ctx);
  //               },
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12)),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // Widget _imageSelectorWidget() {
  //   Size size = MediaQuery.of(context).size;
  //
  //   return Column(
  //     children: [
  //       GestureDetector(
  //         onTap: () {
  //           _showImageSelection();
  //         },
  //         child: Container(
  //           width: size.width > 400 ? 400 : size.width,
  //           height: 70,
  //           margin: const EdgeInsets.symmetric(horizontal: 30),
  //           padding: const EdgeInsets.symmetric(horizontal: 20),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF2F2F2),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           alignment: Alignment.center,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Text(_imageFile != null
  //                   ? "1 Image selected"
  //                   : "Pick image (optional)"),
  //               const Icon(
  //                 Icons.cloud_upload_outlined,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       AnimatedSwitcher(
  //         duration: const Duration(milliseconds: 300),
  //         child: _imageFile != null
  //             ? Container(
  //                 width: size.width > 400 ? 400 : size.width,
  //                 key: UniqueKey(),
  //                 margin: const EdgeInsets.symmetric(horizontal: 30),
  //                 child: Stack(
  //                   children: [
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(18),
  //                       child: Image.file(
  //                         File(_imageFile!.path),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                     Positioned(
  //                       right: 12,
  //                       bottom: 12,
  //                       child: ElevatedButton(
  //                         child: const Icon(Icons.delete_outline_rounded),
  //                         onPressed: () {
  //                           setState(() {
  //                             _imageFile = null;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             : Container(),
  //       ),
  //       const SizedBox(height: 8),
  //     ],
  //   );
  // }
}
