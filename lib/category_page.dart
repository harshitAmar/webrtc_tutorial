import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  final String? categoryId;
  final bool toSelect;
  const CategoryPage({super.key, this.categoryId, this.toSelect = false});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                TextEditingController name = TextEditingController();
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("category")
                              ..doc().set({
                                "name": name.text,
                                "id": DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                "parent": widget.categoryId ?? "main category"
                              }).then((value) {
                                Navigator.pop(context);
                              });
                          },
                          child: Text("Add"))
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("category")
                  .where(
                    'parent',
                    isEqualTo: widget.categoryId ?? "main category",
                  )
                  .snapshots(),
              builder: (context, snap) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snap.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: widget.toSelect
                            ? () {
                                Navigator.pop(
                                    context, snap.data?.docs[index].data());
                              }
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryPage(
                                              categoryId:
                                                  "${snap.data?.docs[index].data()['id'] ?? ""}",
                                            )));
                              },
                        title:
                            Text(snap.data?.docs[index].data()['name'] ?? ""),
                      );
                    });
              }),
          if (widget.categoryId != null && !widget.toSelect) ...[
            SizedBox(
              height: 30,
            ),
            Text("Products"),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .where(
                      'category',
                      arrayContains: widget.categoryId ?? "main category",
                    )
                    .snapshots(),
                builder: (context, snap) {
                  return ListView.builder(
                      itemCount: snap.data?.docs.length ?? 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(snap.data?.docs[index].data()['name'] ?? ""),
                        );
                      });
                }),
          ]
        ],
      ),
    );
  }
}
