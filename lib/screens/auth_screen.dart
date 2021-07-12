import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.9),
                  Colors.blue.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      // transform: transformConfig
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // .. will work similar to . operator, and will not return it's own type,
                      // but the type of its operand i.e Matrix4.rotationZ() in this case
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // color: Colors.amberAccent[700],
                        color: Colors.teal[400],
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Colors.amber[400],
                          // color: Colors.teal[400],
                          fontSize: 45,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: screenSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
//
//
//
//

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  String _name, _email, _password;

  var _isSignup = false;
  var _isLoading = false;
  final _passController = TextEditingController();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _nameFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Animation<Size> _heightAnimation;
  AnimationController _animController;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void dispose() {
    _animController.dispose();
    _passController.dispose();
    _nameFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Controller and Animation not needed for AnimatedContainer
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    //
    // If AnimatedBuilder is not used
    //
    // _heightAnimation = Tween<Size>(
    //   begin: Size(double.infinity, 260),
    //   end: Size(double.infinity, 320),
    // ).animate(CurvedAnimation(
    //   parent: _animController,
    //   curve: Curves.easeInOut,
    // ));
    //
    // _heightAnimation.addListener(() {
    //   setState(() {});
    // });
    //
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInQuad,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -2),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.ease,
    ));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isSignup) {
        await Provider.of<Auth>(context, listen: false)
            .signup(_email, _password, _name);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .login(_email, _password);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
      // print('$error httpExc in _submit auth');
    } catch (error) {
      const errorMessage = 'Failed to authenticate, Please try again later.';
      _showErrorDialog(errorMessage);
      // print('$error in _submit auth');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_isSignup) {
      setState(() {
        _isSignup = false;
      });
      _animController.reverse();
    } else {
      setState(() {
        _isSignup = true;
      });
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    //
    // return AnimatedBuilder(
    //   animation: _heightAnimation,
    //   builder: (ctx, ch) => Container(
    //     height: _heightAnimation.value.height,
    //     constraints: BoxConstraints(
    //       minHeight: _heightAnimation.value.height,
    //     ),
    //     width: deviceSize.width * 0.75,
    //     padding: const EdgeInsets.all(16.0),
    //     child: ch,
    //   ),
    //   child: Form(
    //
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInQuad,
      height: _isSignup ? 380 : 260,
      width: deviceSize.width * 0.75,
      // constraints: BoxConstraints(minHeight: _isSignup ? 320 : 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                key: ValueKey('E-Mail'),
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  if (value.length > 40) {
                    return 'Too long input';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context)
                      .requestFocus(_isSignup ? _nameFocus : _passFocus);
                },
                onSaved: (value) {
                  _email = value.trim();
                },
              ),
              if (_isSignup)
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _isSignup ? 60 : 0,
                    maxHeight: _isSignup ? 120 : 0,
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: _isSignup ? Curves.easeIn : Curves.easeOut,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    // opacity: _animController,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _isSignup,
                        key: ValueKey('name'),
                        focusNode: _nameFocus,
                        decoration: InputDecoration(labelText: 'Name'),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passFocus),
                        validator: (val) {
                          val = val.trim();
                          if (val.isEmpty) {
                            return 'Enter your name';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _name = val.trim();
                        },
                      ),
                    ),
                  ),
                ),
              TextFormField(
                key: ValueKey('password'),
                decoration: InputDecoration(
                  labelText: 'Password',
                  // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                obscureText: true,
                focusNode: _passFocus,
                controller: _passController,
                validator: (value) {
                  value = value.trim();
                  if (value.isEmpty) {
                    return 'Please provide a Password!';
                  }
                  if (value.length < 6) {
                    return 'Password must be of at least 6 characters';
                  }
                  if (value.length > 30) {
                    return 'Password max length is 30 characters';
                  }
                  return null;
                },
                textInputAction:
                    _isSignup ? TextInputAction.next : TextInputAction.done,
                onFieldSubmitted: _isSignup
                    ? (_) => FocusScope.of(context).requestFocus(_confirmFocus)
                    : (_) => _submit(context),
                onSaved: (value) {
                  _password = value.trim();
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _isSignup ? 60 : 0,
                  maxHeight: _isSignup ? 120 : 0,
                ),
                duration: const Duration(milliseconds: 700),
                curve: _isSignup ? Curves.easeIn : Curves.easeOut,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  // opacity: _animController,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      key: ValueKey('confirm'),
                      enabled: _isSignup,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      focusNode: _confirmFocus,
                      validator: _isSignup
                          ? (value) {
                              value = value.trim();
                              if (value != _passController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...{
                ElevatedButton(
                  child: Text(_isSignup ? 'REGISTER' : 'LOGIN'),
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    primary: Colors.tealAccent[700],
                    onPrimary: Colors.white,
                    elevation: 3,
                  ),
                ),
                TextButton(
                  child: Text(_isSignup
                      ? 'I already have an account'
                      : 'Create new account'),
                  onPressed: _switchAuthMode,
                  // style: TextButton.styleFrom(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(30),
                  //   ),
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 30.0, vertical: 4),
                  //   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   primary: Colors.teal,
                  //   // backgroundColor: Colors.black12,
                  //   textStyle: TextStyle(
                  //     fontStyle: FontStyle.italic,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        // side: BorderSide(color: Colors.teal),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal[400]),
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
