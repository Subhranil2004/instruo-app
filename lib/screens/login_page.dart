import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import 'package:instruo_application/widgets/my_button.dart';
import 'package:instruo_application/widgets/my_textfield.dart';
import 'package:instruo_application/home_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    // Validate input
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      displayMessageToUser('Please fill in all fields', context);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      displayMessageToUser('Please enter a valid email address', context);
      return;
    }

    // // Show loading dialog
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      // Ensure user document exists in Firestore
      await ensureUserDocument(userCredential);
      
      // // Close loading dialog
      // if (context.mounted) {
      //   Navigator.pop(context);
      // }
      
    } on FirebaseAuthException catch (e) {
      // // Close loading dialog
      // if (context.mounted) {
      //   Navigator.pop(context);
      // }
      
      // Log authentication errors for debugging
      print("Login failed: ${e.code}");
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      if (context.mounted) {
        displayMessageToUser(errorMessage, context);
      }
    } catch (e) {
      // // Close loading dialog
      // if (context.mounted) {
      //   Navigator.pop(context);
      // }
      
      // Log unexpected errors
      print("Login error: $e");
      if (context.mounted) {
        displayMessageToUser('An unexpected error occurred. Please try again.', context);
      }
    }
  }

  void resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      displayMessageToUser('Please enter your email address', context);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      displayMessageToUser('Please enter a valid email address', context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (context.mounted) {
        displayMessageToUser('Password reset email sent! Check your inbox.', context, isError: false);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      if (context.mounted) {
        displayMessageToUser(errorMessage, context);
      }
    } catch (e) {
      if (context.mounted) {
        displayMessageToUser('An unexpected error occurred. Please try again.', context);
      }
    }
  }

  void skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> ensureUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      String email = userCredential.user!.email!;
      
      try {
        // Check if user document already exists
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(email)
            .get();
        
        // If user document doesn't exist, create it
        if (!userDoc.exists) {
          print("USER DOC NOT FOUND! Creating user document...");
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(email)
              .set({
            'username': email.split('@')[0], // Use email prefix as default username
            'email': email,
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error with user document: $e');
        
        // Check if it's a Firestore database not found error
        if (e.toString().contains('database (default) does not exist')) {
          print('Firestore database not set up. User can still use the app with authentication only.');
          if (context.mounted) {
            displayMessageToUser(
              'Logged in successfully! Note: Profile features require database setup.',
              context,
              isError: false
            );
          }
        }
        
        // Continue with login even if Firestore operations fail
        // User authentication is still working
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                  "assets/fest_logo.png",
                  scale: 1.5,
                  ),
                ),
                // Icon(Icons.person, size: 100, color: Theme.of(context).colorScheme.inversePrimary),
                const SizedBox(height: 10),
                // appname
                const Text('I N S T R U O', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 40),
                // email
                MyTextField(hintText: 'Email', obscureText: false, controller: emailController),
                const SizedBox(height: 20),
            
                // password
                MyTextField(hintText: 'Password', obscureText: true, controller: passwordController),
                const SizedBox(height: 10),
                // forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: resetPassword,
                      child: Text('Forgot Password?', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // signin button
                MyButton(text: 'Sign In', onTap: login),
                const SizedBox(height: 30),
                // don't have an account? signup here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(' Register Here', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // skip login button
                TextButton(
                  onPressed: skipLogin,
                  child: Text(
                    'Skip Login',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'register_page.dart';
// import '../home_page.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   String email = '';
//   String password = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Theme.of(context).colorScheme.surface,
//       // appBar: AppBar(title: Text("Login")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 80.0, bottom: 20.0),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset("assets/fest_logo.png", height: 100),
//                 SizedBox(height: 10),
//                 Text(
//                   "INSTRUO 2025",
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 SizedBox(height: 30),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         decoration: InputDecoration(labelText: "Email"),
//                         onChanged: (val) => email = val,
//                       ),
//                       SizedBox(height: 10),
//                       TextFormField(
//                         decoration: InputDecoration(labelText: "Password"),
//                         obscureText: true,
//                         onChanged: (val) => password = val,
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () {
//                           // TODO: Implement Firebase login
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => HomePage()),
//                           );
//                         },
//                         child: Text("Login"),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => RegisterPage()),
//                           );
//                         },
//                         child: Text("Don't have an account? Register"),
//                       ),
//                       SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () {
//                           // Skip login
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => HomePage()),
//                           );
//                         },
//                         child: Text("Skip Login"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
