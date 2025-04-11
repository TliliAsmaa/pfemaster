import 'package:flutter/material.dart';

class LogoAuth extends StatelessWidget {
  const LogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 6),
                     height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                  color:Color.fromARGB(255, 234, 241, 249),
                    borderRadius: BorderRadius.circular(70),
                    
                  ),
                  child:Image.asset("images/heartbeat.png",//fit: BoxFit.cover,
                  alignment: Alignment.center,
                 
                  ),
                
                  ),
              );
  }
}