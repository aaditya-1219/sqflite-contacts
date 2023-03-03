import 'package:flutter/material.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:sqflite_contacts/sql_helper.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomePage(),
    ));

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;


  // Colors
  final addButtonColor = const Color.fromARGB(255, 57, 91, 100);
  final appBarColor = const Color.fromARGB(255, 44, 51, 51);
  final cardColor = const Color.fromARGB(255, 164, 201, 202);
  final appBgColor = const Color.fromARGB(255, 231, 246, 242);

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();

    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print("..number of contacts ${_journals.length}");
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _nameController.text,
      _phoneController.text,
      _emailController.text,
      _streetController.text,
      _cityController.text
    );
    _refreshJournals();
    print("Number of items ${_journals.length}");
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id,
        _nameController.text,
        _phoneController.text,
        _emailController.text,
        _streetController.text,
        _cityController.text);
    _refreshJournals();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Successfully deleted')
      )
    );
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _phoneController.text = existingJournal['phone'];
      _emailController.text = existingJournal['email'];
      _streetController.text = existingJournal['street'];
      _cityController.text = existingJournal['city'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        backgroundColor: appBgColor,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,

                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    style: TextStyle(fontFamily: GoogleFonts.merriweather().fontFamily),
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(fontFamily: GoogleFonts.merriweather().fontFamily),
                    controller: _phoneController,
                    decoration: const InputDecoration(hintText: 'Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(fontFamily: GoogleFonts.merriweather().fontFamily),
                    controller: _emailController,
                    decoration:
                        const InputDecoration(hintText: 'Email Address'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(fontFamily: GoogleFonts.merriweather().fontFamily),
                    controller: _streetController,
                    decoration: const InputDecoration(hintText: 'Street'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(hintText: 'City'),
                    style: TextStyle(fontFamily: GoogleFonts.merriweather().fontFamily),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: addButtonColor
                      ),
                      onPressed: () async {
                        if(id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                      //  Clear the text fields
                        _nameController.text = '';
                        _phoneController.text = '';
                        _emailController.text = '';
                        _streetController.text = '';
                        _cityController.text = '';

                        // CLose the bottom popup
                        Navigator.of(context).pop();
                      },
                    child: Text(id == null ? 'Create New' : 'Update', style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily), ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(title: Text('Contacts', style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily, fontSize: 26)), backgroundColor: appBarColor),
      body: ListView.builder(
        itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
            color: cardColor,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text("Name: " + _journals[index]['name'], style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.merriweather().fontFamily)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text("Phone: " + _journals[index]['phone'], style: TextStyle(color: Colors.black54, fontFamily: GoogleFonts.merriweather().fontFamily),),
                  SizedBox(height: 10),
                  Text("Email: " + _journals[index]['email'], style: TextStyle(color: Colors.black54, fontFamily: GoogleFonts.merriweather().fontFamily),),
                  SizedBox(height: 10),
                  Text("Street: " + _journals[index]['street'], style: TextStyle(color: Colors.black54, fontFamily: GoogleFonts.merriweather().fontFamily),),
                  SizedBox(height: 10),
                  Text("City: " + _journals[index]['city'], style: TextStyle(color: Colors.black54, fontFamily: GoogleFonts.merriweather().fontFamily),),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_journals[index]['id']),
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(_journals[index]['id']),
                    )
                  ]
                )
              ),
            )
          )
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          backgroundColor: addButtonColor,
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        );
      }),
    );
  }
}
