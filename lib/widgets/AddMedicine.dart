import 'package:flutter/material.dart';
import '../database/moor_database.dart';
import '../notifications/NotificationManager.dart';

class AddMedicine extends StatefulWidget {
  final double height;
  final AppDatabase _database;
  final NotificationManager manager;
  AddMedicine(this.height, this._database, this.manager);

  @override
  _AddMedicineState createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  static final _formKey = new GlobalKey<FormState>();
  String _name;
  String _dose;

  int _selectedIndex = 0;
  List<String> _icons = [
    'drug.png',
    'inhaler.png',
    'pill_rounded.png',
    'pill.png',
    'syringe.png',
    'ointment.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(25, 25, 25, 0),
        height: widget.height * .7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Add Medicine Now',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // back to main screen
                    Navigator.pop(context, null);
                  },
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Theme.of(context).primaryColor.withOpacity(.65),
                  ),
                )
              ],
            ),
            _buildForm(),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Model',
                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            _buildShapesList(),
            SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  _submit(widget.manager);
                },
                color: Theme.of(context).accentColor,
                textColor: Colors.black54,
                highlightColor: Theme.of(context).primaryColor,
                child: Text(
                  'Add Medicine'.toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildShapesList() {
    return Container(
      width: double.infinity,
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _icons
            .asMap()
            .entries
            .map((MapEntry map) => _buildIcons(map.key))
            .toList(),
      ),
    );
  }

  Form _buildForm() {
    TextStyle labelsStyle =
        TextStyle(fontWeight: FontWeight.w400, fontSize: 25);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            style: TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Medicine Name',
              labelStyle: labelsStyle,
            ),
            validator: (input) => (input.length < 5) ? 'Name is short' : null,
            onSaved: (input) => _name = input,
          ),
          TextFormField(
            style: TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Dosage',
              labelStyle: labelsStyle,
            ),
            validator: (input) => (input.length > 50) ? 'Dose is long' : null,
            onSaved: (input) => _dose = input,
          )
        ],
      ),
    );
  }

  void _submit(NotificationManager manager) async {
    if (_formKey.currentState.validate()) {
      // form is validated
      _formKey.currentState.save();
      print(_name);
      print(_dose);
      //show the time picker dialog
      showTimePicker(
        initialTime: TimeOfDay.now(),
        context: context,
      ).then((selectedTime) async {
        int hour = selectedTime.hour;
        int minute = selectedTime.minute;
        print(selectedTime);
        // insert into database
        var medicineId = await widget._database.insertMedicine(
            MedicinesTableData(
                name: _name,
                dose: _dose,
                image: 'assets/images/' + _icons[_selectedIndex]));
        // sehdule the notification
        manager.showNotificationDaily(medicineId, _name, _dose, hour, minute);
        // The medicine Id and Notitfaciton Id are the same
        print('New Med id' + medicineId.toString());
        // go back
        Navigator.pop(context, medicineId);
      });
    }
  }

  Widget _buildIcons(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: (index == _selectedIndex)
              ? Theme.of(context).accentColor.withOpacity(.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Image.asset('assets/images/' + _icons[index]),
      ),
    );
  }
}
