/*import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller ;
  final String? Function(String?)? validator;
   final bool isPassword;
  final bool obscureText=true;
  const CustomTextFormField({super.key, required this.hinttext, required this.mycontroller, this.validator, this.isPassword=false, this.obscureText ,});


  @override
  Widget build(BuildContext context) {
    return  TextFormField(

      validator: validator,
      obscureText: obscureText,
                  controller : mycontroller,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 16,color: Colors.grey),
                    hintText: hinttext,
                    contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                    filled:true,
                    fillColor: Color.fromARGB(255, 234, 241, 249),
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    
                  ),
                 );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class CustomTextFormField extends StatefulWidget {
  final List<TextInputFormatter>? inputFormatters;
  final String hinttext;
  final TextEditingController mycontroller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextStyle? hintStyle;
   final TextInputType keyboardType; 
  const CustomTextFormField({
    super.key,
    required this.hinttext,
    required this.mycontroller,
    this.validator,
    this.hintStyle,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    // Si ce n’est pas un champ de mot de passe, on ne cache pas le texte
    if (!widget.isPassword) {
      obscureText = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      

      inputFormatters: widget.inputFormatters,
       keyboardType: widget.keyboardType,
      validator: widget.validator,
      controller: widget.mycontroller,
      obscureText: obscureText,
      decoration: InputDecoration(
       hintStyle: widget.hintStyle ?? const TextStyle(fontSize: 14,  color: Colors.blueGrey,),
        hintText: widget.hinttext,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        filled: true,
        fillColor: const Color.fromARGB(255, 234, 241, 249),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  
                  });
                },
              )
            : null,
      ),
    );
  }
}
