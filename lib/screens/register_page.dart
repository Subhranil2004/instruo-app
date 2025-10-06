import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import 'package:instruo_application/main.dart';
import 'package:instruo_application/widgets/my_button.dart';
import 'package:instruo_application/widgets/my_textfield.dart';
import 'package:instruo_application/home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void registerUser() async {
    // Validate input
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      displayMessageToUser('Please fill in all fields', context);
      return;
    }

    if (nameController.text.trim().length < 3) {
      displayMessageToUser('Name must be at least 3 characters long', context);
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
      displayMessageToUser('Please enter a valid email address', context);
      return;
    }

    // password confirmation
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser('Passwords do not match', context);
      return;
    }

    // // Show loading dialog
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );

    try {
      // create user
      UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // create a user doc and add to firestore
      await createUserDocument(userCredential);
      
      // // Close loading dialog
      // if (context.mounted) {
      //   Navigator.pop(context);
      // }

    } on FirebaseAuthException catch (e) {
      // // Close loading dialog
      // Navigator.pop(context);

      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      
      if (context.mounted) {
        displayMessageToUser(errorMessage, context);
      }
    } 
    // catch (e) {
    //   // // Close loading dialog
    //   // if (context.mounted) {
    //   //   Navigator.pop(context);
    //   // }
      
    //   if (context.mounted) {
    //     displayMessageToUser('An unexpected error occurred. Please try again.', context);
    //   }
    // }
  }

  void skipRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    // Add additional user details to Firestore
    if (userCredential != null && userCredential.user != null) {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      
      try {
        // Create the user document
        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'phone': '', // To be filled later from profile page
          'iiestian': true, // Default to true, can be updated later
          'collegeName': 'IIEST', // To be filled later from profile page
          'year': '', // To be filled later from profile page
          'department': '', // Optional
          'isCoordinator': false, // Default to false, can be updated later
          'coordinatingEvents': <String>[], // Empty list, to be filled later from profile page
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(email) // Use email as the document ID
            .set(userData);

        rootScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar( 
            content: Text('✅ Registered successfully\nℹ️ Fill profile details before event registration'),
            duration: Duration(seconds: 5),
          ),
        );

      } catch (e) {
        displayMessageToUser('Error creating user document: $e', context);
        
        // Check if it's a Firestore database not found error
        if (e.toString().contains('database (default) does not exist')) {
          print('Firestore database not set up. User can still use the app with authentication only.');
          if (context.mounted) {
            displayMessageToUser(
              'Account created successfully! Note: Profile features require database setup.',
              context,
              isError: false
            );
          }
        } else {
          // For other errors, show a generic message
          if (context.mounted) {
            displayMessageToUser(
              'Account created but profile setup failed. You can still use the app.',
              context,
              isError: false
            );
          }
        }
        
        // Still allow the user to proceed even if document creation fails
        // The AuthPage will handle the redirect based on auth state
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
                const SizedBox(height: 20),
                // appname
                Text('I N S T R U O', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 40),
                // name
                MyTextField(hintText: 'Name', obscureText: false, controller: nameController),
                const SizedBox(height: 20),
            
                // email
                MyTextField(hintText: 'Email', obscureText: false, controller: emailController),
                const SizedBox(height: 20),
            
                // password
                MyTextField(hintText: 'Password', obscureText: true, controller: passwordController),
                const SizedBox(height: 20),
            
                // confirm password
                MyTextField(hintText: 'Confirm Password', obscureText: true, controller: confirmPasswordController),
                const SizedBox(height: 20),
            
                // register button
                MyButton(text: 'Register', onTap: registerUser),
                const SizedBox(height: 30),
                // already have an account? login here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(' Login Here', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // skip register button
                TextButton(
                  onPressed: skipRegister,
                  child: Text(
                    'Skip Registration',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).textTheme.titleMedium?.color,
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
// import '../home_page.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   String name = '';
//   String email = '';
//   String password = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text("Register")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 80.0, bottom: 20.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Image.asset("assets/fest_logo.png", height: 100),
//                 SizedBox(height: 10),
//                 Text(
//                   "INSTRUO 2025",
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 30),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         decoration: InputDecoration(labelText: "Name"),
//                         onChanged: (val) => name = val,
//                       ),
//                       SizedBox(height: 10),
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
//                           // TODO: Implement Firebase registration
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => HomePage()),
//                           );
//                         },
//                         child: Text("Register"),
//                       ),
//                       SizedBox(height: 10),
//                       TextButton(
//                         onPressed: () {
//                           // Skip registration
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => HomePage()),
//                           );
//                         },
//                         child: Text("Skip Registration"),
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
