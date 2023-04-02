import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_powerbox/welcome.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login/Sign up"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(labelText: "Login"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Login is required";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            _isLoading = true;
                          });
                          final response = await http.post(
                            Uri.parse(
                                "https://mother.powerpbox.org/my_controller/my_post_api"),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                              'Authorization': 'Basic ' +
                                  base64Encode(utf8.encode(
                                      '$_loginController.text:$_passwordController.text')),
                            },
                            body: jsonEncode(<String, String>{
                              'name': _nameController.text,
                              'login': _loginController.text,
                              'password': _passwordController.text,
                            }),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          if (response.statusCode == 200) {
                            // User created successfully
                            // Getting the access token from the response
                            final token =
                                jsonDecode(response.body)['access_token'];
                            print(token);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen()),
                            );
                            // TODO: Navigate to the next screen with the token
                          } else {
                            // User creation failed
                            // Show the error message from the API
                            final errorMessage =
                                jsonDecode(response.body)['message'];
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Error"),
                                content: Text(errorMessage),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ),
                            );
                          }
                        }
                      },
                child:
                    _isLoading ? CircularProgressIndicator() : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
