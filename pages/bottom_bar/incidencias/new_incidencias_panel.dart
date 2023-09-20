import 'package:mi_comunidad/services/database.dart';
import 'package:flutter/material.dart';
import 'package:mi_comunidad/Shared/constants.dart';

class NewIncidenciasPanel extends StatefulWidget {
  const NewIncidenciasPanel({Key? key, required this.community})
      : super(key: key);
  final String? community;

  @override
  State<NewIncidenciasPanel> createState() => _NewIncidenciasPanelState();
}

class _NewIncidenciasPanelState extends State<NewIncidenciasPanel> {
  final _formKey = GlobalKey<FormState>();

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
                child:
                    Text('Crea la incidencia', style: TextStyle(fontSize: 18))),
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
                ])),
            const SizedBox(height: 20),
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: const Color(0xFF344B6A)),
                child:
                    const Text('Crear', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseService(communityName: widget.community)
                        .updateIncidenciasData(_currentName, false);
                    Navigator.pop(context);
                  }
                }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
