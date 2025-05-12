import 'package:flutter/material.dart';

class EditFieldPage extends StatefulWidget {
  final String field;
  final String currentValue;

  const EditFieldPage({required this.field, required this.currentValue, Key? key}) : super(key: key);

  @override
  _EditFieldPageState createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late TextEditingController _textController;
  late TextEditingController _dateController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue);
    _dateController = TextEditingController(text: widget.currentValue);
    _selectedGender = widget.currentValue.toLowerCase();
  }

  void _save(String value) {
    Navigator.pop(context, value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isBirthDate = widget.field == 'birth date';
    final isGender = widget.field == 'gender';

    return Scaffold(
       backgroundColor:  Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text("Modifier ${widget.field}"),
       backgroundColor:  Color(0xFFF7FBFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isBirthDate)
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Choisir votre date de naissance",
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  fillColor: Color.fromARGB(255, 234, 241, 249),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final today = DateTime.now();
                  final fortyYearsAgo = DateTime(today.year - 40, today.month, today.day);
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: fortyYearsAgo,
                    firstDate: DateTime(1900),
                    lastDate: fortyYearsAgo,
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre date de naissance";
                  }
                  return null;
                },
              )
            else if (isGender)
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ["male", "female"]
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 234, 241, 249),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez choisir votre sexe";
                  }
                  return null;
                },
              )
            else
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: "Nouvelle valeur",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _save(
                isBirthDate
                    ? _dateController.text
                    : isGender
                        ? _selectedGender ?? ""
                        : _textController.text,
              ),
          child:  Text("enregistrer",style: TextStyle(fontSize: 16,color:Color(0xFF4A90E2)),),
              style:  ElevatedButton.styleFrom(
                             minimumSize: Size(150, 50),
                             backgroundColor:  Colors.white,
                            //backgroundColor: Color.fromARGB(255, 255, 255, 255),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: StadiumBorder(),
                          ),
            ),
          ],
        ),
      ),
    );
  }
}

