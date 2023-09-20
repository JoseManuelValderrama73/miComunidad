import 'package:flutter/material.dart';
import 'package:mi_comunidad/services/database.dart';
import 'package:mi_comunidad/Shared/constants.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class NewReunionesPanel extends StatefulWidget {
  const NewReunionesPanel({Key? key, required this.community})
      : super(key: key);
  final String? community;

  @override
  State<NewReunionesPanel> createState() => _NewIncidenciasPanelState();
}

class _NewIncidenciasPanelState extends State<NewReunionesPanel> {
  final _formKey = GlobalKey<FormState>();
  dynamic _date = DateTime.now();
  String _alertText = '';
  String _dateButtonText = 'Seleccione la fecha';
  String _timeButtonText = 'Seleccione la hora';
  bool datePressed = false;
  bool timePressed = false;
  final TextEditingController _timeController = TextEditingController();

  Future _showDatePicker() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      confirmText: '0K',
      cancelText: 'CANCELAR',
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF344B6A), // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Color(0xFF344B6A), // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEE9E83), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null && selectedDate != _date) {
      setState(() {
        _alertText = '';
        _date = DateFormat('dd/MM/yyyy').format(selectedDate);
        _dateButtonText = _date;
      });
    } else {
      setState(() {
        _alertText = 'No se ha especificado una fecha';
        _date = _date.toString();
        _date = '-';
      });
    }
  }

  Future _showTimePicker() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      confirmText: '0K',
      cancelText: 'CANCELAR',
      initialTime: const TimeOfDay(hour: 00, minute: 00),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF344B6A), // <-- SEE HERE
              onPrimary: Colors.white, // <-- SEE HERE
              onSurface: Color(0xFF344B6A), // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEE9E83), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedTime != null) {
      setState(() {
        _alertText = '';
        _timeController.text = formatDate(
            DateTime(2019, 8, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();

        _timeButtonText = _timeController.text;
      });
    } else {
      setState(() {
        _alertText = 'No se ha especificado una hora';
        _date = _date.toString();
        _date = '-';
      });
    }
  }

  String? _currentName;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('Crea la reunión', style: TextStyle(fontSize: 18))),
            const SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Descripción'),
                    validator: (val) =>
                        val!.isEmpty ? 'Introduce una descripción' : null,
                    onChanged: (val) {
                      setState(() => _currentName = val);
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: Container(
                      color: Colors.white,
                      child: TextButton(
                          child: Text(_dateButtonText,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF344B6A),
                                  letterSpacing: 0)),
                          onPressed: () {
                            _showDatePicker();
                            setState(() {
                              datePressed = true;
                            });
                          }),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Container(
                      color: Colors.white,
                      child: TextButton(
                          child: Text(_timeButtonText,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF344B6A),
                                  letterSpacing: 0)),
                          onPressed: () {
                            _showTimePicker();
                            setState(() {
                              timePressed = true;
                            });
                          }),
                    ),
                  )
                ])),
            const SizedBox(height: 10),
            Text(_alertText,
                style: const TextStyle(fontSize: 15, color: Colors.red)),
            const SizedBox(height: 10),
            Visibility(
              visible: datePressed && timePressed,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF344B6A)),
                  child: const Text('Crear',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(communityName: widget.community)
                          .updateReunionesData(
                              _date + ' a las ' + _timeController.text,
                              _currentName);
                      Navigator.pop(context);
                    }
                  }),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
