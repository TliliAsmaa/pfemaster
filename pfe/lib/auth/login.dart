//import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
bool isloading =false;

  

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

 final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
   
    if (user != null) {
    // 🔍 Vérifie si l'utilisateur existe déjà dans Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      print('Document exists.');
      // L'utilisateur existe déjà, aller à la page d'accueil
      Navigator.of(context).pushNamedAndRemoveUntil("AuthWrapper", (route) => false);
    } else {
      print("new inscription Google");
      // L'utilisateur est nouveau, rediriger vers la page pour compléter le profil
      Navigator.of(context).pushNamedAndRemoveUntil("googleSignupComplete", (route) => false);
    }
  }
    
 // Navigator.of(context).pushNamedAndRemoveUntil("homepage", (route)=> false);
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
     body: isloading ? Center(child:CircularProgressIndicator()): Container(
      padding:EdgeInsets.all(20),
      child:ListView(
        children: [
          
          
          Form(
            key:formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height:50,),
                LogoAuth(),
                Container(height:20),
                  Text("Se connecter",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                   Container(height:10),
                  Text("Connecte toi pour continuer à utiliser l'application",style:TextStyle(color: Colors.grey)),
                   Container(height:20),
                   Text("Email",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                    Container(height:10),
                    CustomTextFormField(
                    hinttext: "Saisir votre adresse email",
                    mycontroller: email,
                    validator: (val) {
                      if(val==""){
                        return "veuiller saisir votre adresse email";
                      }
                     return null;
                    }
                    ),
                    Container(height:10),
                   Text("Mot de passe",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                   Container(height:10),
                   CustomTextFormField(
                    
                    hinttext: "Saisir votre mot de passe",
                   isPassword: true,
                    mycontroller: password,
                     validator: (val) {
                      if(val==""){
                        return "veuiller saisir votre mot de passe";
                      }
                     return null;
                    }
                   ),
                   InkWell(
                    onTap: () async{
                      if(email.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Veuillez saisir votre adresse email")));
                      }else{
                        
                          try {
                                 await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                                  AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.rightSlide,
                        title: 'Info',
                        desc: 'Veuillez vérifier votre adresse email pour réinitialiser votre mot de passe',
                        btnOkOnPress: () async {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-mail de réinitialisation du mot de passe envoyé")));}).show();
                             } on Exception catch (e) {
                                print('Error sending password reset email: $e');
                                
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilisateur n'existe pas"),duration: const Duration(milliseconds: 800),));
                                 }
                        
                   
                      }
                     
                    },
                     child: Container(
                      margin:EdgeInsets.only(top:10,bottom:20),
                      alignment: Alignment.topRight,
                       child: Text("Mot de passe oublié?",
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
                  color: const Color.fromRGBO(68, 138, 255, 1),
                  child: Text("Se connecter",style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  shape: RoundedRectangleBorder(
                   
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  
                  onPressed: () async {
                    if(formkey.currentState!.validate()){
                            try {
                               //isloading =true;
                                /*setState(() {
                                  isloading = true;
                                });*/
  final credential =await FirebaseAuth.instance.signInWithEmailAndPassword(
    
    email: email.text,
    password: password.text,
  );
  //isloading=false;
  setState(() {
    isloading=false;
  });
  await Future.delayed(Duration(milliseconds: 500)); 
  if(credential.user!.emailVerified){
    
    Navigator.of(context).pushReplacementNamed('AuthWrapper');
    //ajouter un nouvel utilisateur dans la base de donnees

         
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
     setState (() {
                         isloading = false;
                    });
    print('=====================================================user not found.');
   /* AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Error',
            desc: 'user not found',
           
            ).show();*/
             ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("utilisateur non trouvé")),
                        );
  }
  else if (e.code == 'wrong-password') {
    setState(() {
                         isloading = false;
                    });
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
                          SnackBar(content: Text("Mot de passe incorect")),
                        );
                       } 
  }
  }
                    },
                  ),
                Container(height:20),
                Text("Ou connecter avec",textAlign: TextAlign.center,),
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
                      text: "vous n'avez pas de compte? ",
                      style: TextStyle(color: Colors.black,fontSize: 15),
                    ),
                    TextSpan(
                      text: "s'inscrire",
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
