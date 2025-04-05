//import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfemaster/component/logoauth.dart';
import 'package:pfemaster/component/textformfield.dart';
import 'package:google_sign_in/google_sign_in.dart';
class Login extends StatefulWidget {
  const Login({super.key}) ;
@override
State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();


  

Future signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if(googleUser == null) {
      return;
    }
  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  await FirebaseAuth.instance.signInWithCredential(credential);
  Navigator.of(context).pushNamedAndRemoveUntil("homepage", (route)=> false);
}
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF7FBFF),
       
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: Colors.black,),
          onPressed: (){
           Navigator.of(context).pushNamedAndRemoveUntil("onboardingscreen", (route)=> false);
          },
        ),
        
      ),
      backgroundColor: Color(0xFFF7FBFF),
     body:Container(
      padding:EdgeInsets.all(20),
      child:ListView(
        children: [
          
          
          Form(
            key:formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height:80,),
                LogoAuth(),
                Container(height:20),
                  Text("Login",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                   Container(height:10),
                  Text("Login to continue using the app",style:TextStyle(color: Colors.grey)),
                   Container(height:20),
                   Text("Email",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                    Container(height:10),
                    CustomTextFormField(
                    hinttext: "Enter your email",
                    mycontroller: email,
                    validator: (val) {
                      if(val==""){
                        return "Please enter your email";
                      }
                     return null;
                    }
                    ),
                    Container(height:10),
                   Text("Password",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                   Container(height:10),
                   CustomTextFormField(
                    
                    hinttext: "Enter your password",
                   isPassword: true,
                    mycontroller: password,
                     validator: (val) {
                      if(val==""){
                        return "Please enter your password";
                      }
                     return null;
                    }
                   ),
                   InkWell(
                    onTap: () async{
                      if(email.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter your email")));
                      }else{
                        
                          try {
                                 await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                                  AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Info',
                        desc: 'Please check your email for password reset link',
                        btnOkOnPress: () async {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset email sent")));}).show();
                             } on Exception catch (e) {
                                print('Error sending password reset email: $e');
                                
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("no user found for that email"),duration: const Duration(milliseconds: 800),));
                                 }
                        
                   
                      }
                     
                    },
                     child: Container(
                      margin:EdgeInsets.only(top:10,bottom:20),
                      alignment: Alignment.topRight,
                       child: Text("Forgot Password?",
                       textAlign: TextAlign.right,
                       style:TextStyle(color: Colors.black,fontSize: 14,)),
                     ),
                   ),
                   
              ],
              
            ),
          ),
           MaterialButton(
            height:50,
                  textColor: Colors.white,
                  color: Colors.blueAccent,
                  child: Text("Login",style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  shape: RoundedRectangleBorder(
                   
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  
                  onPressed: () async {
                    if(formkey.currentState!.validate()){
                            try {
  final credential =await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email.text,
    password: password.text,
  );
  if(credential.user!.emailVerified){
    Navigator.of(context).pushReplacementNamed('homepage');
    }else{
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Please verify your email first',
        btnOkOnPress: () {},
      ).show();
    }
}  on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    print('=====================================================user not found.');
   /* AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Error',
            desc: 'user not found',
           
            ).show();*/
             ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("user not found")),
                        );
  }
  else if (e.code == 'wrong-password') {
    print('=====================================================wrong password.');
   /* AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Error',
            desc: 'wrong password',
           
            ).show();
            */
             ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("wrong password")),
                        );}
  }
  }
                    },
                  ),
                Container(height:20),
                Text("Or Login with",textAlign: TextAlign.center,),
            Column(
              children: [
                MaterialButton(onPressed:(){
                  signInWithGoogle();
                },
                
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
               
                height:50,
                           
                child:Image.asset('images/google.png',height:80,width:80,),
                ),

              ],
            ),
            Container(height:20),
            InkWell(
              onTap: (){
                Navigator.of(context).pushReplacementNamed('SignUp');
              },
              child: Center(
                child: Text.rich(TextSpan(
                 
                   children:[
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black,fontSize: 15),
                    ),
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(color: Colors.blueAccent,fontSize: 15,fontWeight: FontWeight.bold),
                     
                    )
                   ],
                ),
                 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
