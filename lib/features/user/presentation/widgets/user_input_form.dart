import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final Function(String) onGenderChanged;
  final Function(int) onAgeSaved;

  const UserInputForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.onGenderChanged,
    required this.onAgeSaved,
  });

  @override
  _UserInputFormState createState() => _UserInputFormState();
}

// Custom TextInputFormatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.toUpperCase();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _UserInputFormState extends State<UserInputForm> {
  String _selectedGender = 'Male'; // Default value

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // align center

          Center(
            child: Text(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                "Who's There?"),
          ),
          SizedBox(height: 16),
          TextFormField(
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            controller: widget.usernameController,
            inputFormatters: [
              UpperCaseTextFormatter(), // Forces uppercase input
            ],
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Gender Dropdown
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
                widget.onGenderChanged(value);
              });
            },
          ),
          SizedBox(height: 16),

          // Age Field
          TextFormField(
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final parsedValue = int.tryParse(value);
              if (parsedValue == null || parsedValue <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
            onSaved: (value) {
              widget.onAgeSaved(int.parse(value!));
            },
          ),
        ],
      ),
    );
  }
}
