import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sqlite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD SQFLITE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'CRUD SQFLITE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController judulController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();


  @override
  void initState() {
    refreshCatatan();
    super.initState();
  }


  //ambil data dari database
  List<Map<String, dynamic>> catatan = [];
  void refreshCatatan() async {
    final data = await SQLHelper.getCatatan();
    setState(() {
      catatan = data;
    });
  }

  //fungsi tambah
  Future<void> tambahCatatan() async{
    await SQLHelper.tambahCatatan(
        judulController.text, deskripsiController.text);
    refreshCatatan();
  }

  //fungsi update
  Future<void> updateCatatan(int id) async{
    await SQLHelper.ubahCatatan(
        id, judulController.text, deskripsiController.text);
    refreshCatatan();
  }

  //fungsi hapus
  Future<void> hapusCatatan(int id) async {
    await SQLHelper.hapusCatatan(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Berhasil hapus catatan')));
    refreshCatatan();
  }

  //form tambah
  void modalForm(int id) async {
    if (id != 0) {
      final dataCatatan = catatan.firstWhere((element) => element['id'] == id);
      judulController.text = dataCatatan['judul'];
      deskripsiController.text = dataCatatan['deskripsi'];
    }
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          height: 800,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:  [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(hintText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(hintText: 'Deskripsi'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (id == 0) {
                        await tambahCatatan();
                      } else {
                        await updateCatatan(id);
                      }
                      judulController.text = '';
                      deskripsiController.text = '';
                      Navigator.pop(context);
                    },
                    child:  Text(id == 0 ? 'tambah' : 'ubah')
                )
              ],
            )
          ),
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    print(catatan);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: catatan.length,
          itemBuilder: (context, index) => Card(
            margin: EdgeInsets.all(15),
            child: ListTile(
              title: Text(catatan[index]['judul']),
              subtitle: Text(catatan[index]['deskripsi']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => modalForm(catatan[index]['id']),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => hapusCatatan(catatan[index]['id']),
                        icon: Icon(Icons.delete))
                  ],
                ),
              ),
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalForm(0);
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
