import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_tutorial/category_page.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<Map<String, dynamic>> category = [];
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(
        child: Column(
          children: [
            Wrap(
              children: category
                  .map((e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(onPressed: () {}, child: Text(e['name'])),
                      ))
                  .toList(),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (conmtext) => CategoryPage(
                                toSelect: true,
                                categoryId: category.isEmpty
                                    ? null
                                    : category.last['id'],
                              ))).then((value) {
                    if (value is Map<String, dynamic>) {
                      category.add(value);
                      setState(() {});
                    }
                  });
                },
                child: Text("Select Category")),
            TextField(
              controller: nameController,
            ),
            ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection("products").doc().set({
                    "name": nameController.text,
                    "id": DateTime.now(),
                    "category": category.map((e) => e['id']).toList(),
                  }).then((value) {
                    category.clear();
                    nameController.clear();
                    setState(() {});
                  });
                },
                child: Text("Add Product"))
          ],
        ),
      ),
    );
  }
}
