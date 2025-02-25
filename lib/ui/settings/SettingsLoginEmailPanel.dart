import 'package:flutter/material.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/ui/widgets/TabBar.dart' as uiuc;
import 'package:illinois/utils/AppUtils.dart';
import 'package:rokwire_plugin/model/auth2.dart';
import 'package:rokwire_plugin/service/auth2.dart';
import 'package:rokwire_plugin/service/localization.dart';
import 'package:rokwire_plugin/service/styles.dart';
import 'package:rokwire_plugin/ui/widgets/header_bar.dart';
import 'package:rokwire_plugin/ui/widgets/rounded_button.dart';
import 'package:rokwire_plugin/utils/utils.dart';

class SettingsLoginEmailPanel extends StatefulWidget {

  final String? email;
  final bool? link;
  final Auth2EmailAccountState? state;
  final void Function()? onFinish;

  SettingsLoginEmailPanel({this.email, this.state, this.link, this.onFinish});

  _SettingsLoginEmailPanelState createState() => _SettingsLoginEmailPanelState();
}

class _SettingsLoginEmailPanelState extends State<SettingsLoginEmailPanel>  {

  static final Color? _successColor = Colors.green.shade800;
  static final Color? _errorColor = Colors.red.shade700;
  static final Color? _messageColor = Styles().colors?.fillColorPrimary;
  
  TextEditingController _emailController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _passwordFocusNode = FocusNode();
  TextEditingController _confirmPasswordController = TextEditingController();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  
  String? _validationErrorText;
  Color? _validationErrorColor;
  GlobalKey _validationErrorKey = GlobalKey();

  bool _isSiging = false;
  bool _isCanceling = false;
  bool _isShowingPassword = false;

  Auth2EmailAccountState? _state;

  @override
  void initState() {
    _emailController.text = widget.email!;
    _state = widget.state;
    super.initState();
    if (_state == Auth2EmailAccountState.unverified) {
      _validationErrorText = Localization().getStringEx("panel.onboarding2.email.sign_up.succeeded.text", "A verification email has been sent to your email address. To activate your account you need to confirm it. Then you will be able to login with your new credential.");
      _validationErrorColor = _messageColor;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String title = (_state == Auth2EmailAccountState.nonExistent) ?
      (widget.link == true) ? Localization().getStringEx('panel.settings.link.email.label.title', 'Add Email Address') :
      Localization().getStringEx('panel.onboarding2.email.sign_up.title.text', 'Sign Up with Email') :
      Localization().getStringEx('panel.onboarding2.email.sign_in.title.text', 'Sign In with Email');

    String? headingTitle; //((_state == Auth2EmailAccountState.nonExistent) && (widget.link == true)) ? Localization().getStringEx('panel.onboarding2.email.link.title.text', 'Add Your Email Address') : null;

    String? heading; //((_state == Auth2EmailAccountState.nonExistent) && (widget.link == true)) ? Localization().getStringEx('panel.settings.link.email.label.description', 'You may sign in using your email as an alternative way to sign in. Some features of the Illinois App will not be available unless you login with your NetID.') : null;

    String description = (_state == Auth2EmailAccountState.nonExistent) ?
      (widget.link == true) ? Localization().getStringEx('panel.onboarding2.email.link.description.text', 'Please enter a password to add your email address.') :
      Localization().getStringEx('panel.onboarding2.email.sign_up.description.text', 'Please enter a password to create a new account for your email.') :
      Localization().getStringEx('panel.onboarding2.email.sign_in.description.text', 'Please enter your password to sign in with your email.');

    String showPassword = (_state == Auth2EmailAccountState.nonExistent) ?
      Localization().getStringEx("panel.onboarding2.email.label.show_passwords.text", "Show Passwords") :
      Localization().getStringEx("panel.onboarding2.email.label.show_password.text", "Show Password");

    String buttonTitle = (_state == Auth2EmailAccountState.nonExistent) ?
      (widget.link == true) ? Localization().getStringEx('panel.onboarding2.email.button.link.text', 'Add') :
      Localization().getStringEx('panel.onboarding2.email.button.sign_up.text', 'Sign Up') :
      Localization().getStringEx('panel.onboarding2.email.button.sign_in.text', 'Sign In');

    String buttonHint = (_state == Auth2EmailAccountState.nonExistent) ?
      (widget.link == true) ? Localization().getStringEx('panel.onboarding2.email.button.link.hint', '') :
      Localization().getStringEx('panel.onboarding2.email.button.sign_up.hint', '') :
      Localization().getStringEx('panel.onboarding2.email.button.sign_in.hint', '');

    InputDecoration textFeildDecoration = InputDecoration(
      disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles().colors!.mediumGray!, width: 1.0),),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles().colors!.mediumGray!, width: 1.0),),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles().colors!.mediumGray!, width: 1.0),),
    );

    return Scaffold(
      appBar: HeaderBar(title: title,),
      body: Column(children: <Widget>[
        Expanded(child:
          SingleChildScrollView(scrollDirection: Axis.vertical, child:
            Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                
                (heading != null) ? 
                  Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(bottom: 24), child:
                      Text(heading, style: TextStyle(fontFamily: Styles().fontFamilies?.regular, fontSize: 18, color: Styles().colors!.fillColorPrimary),)
                  ),)],) : Container(),

                (headingTitle != null) ? 
                  Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(bottom: 24), child:
                    Text(headingTitle, textAlign: TextAlign.center, style: TextStyle(fontFamily: Styles().fontFamilies?.bold, fontSize: 36, color: Styles().colors!.fillColorPrimary),)
                  ),)],) : Container(),

                Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(bottom: 24), child:
                  Text(description, style: TextStyle(fontFamily: Styles().fontFamilies?.regular, fontSize: 18, color: Styles().colors!.fillColorPrimary),)
                ),)],),

                Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(bottom: 6), child:
                  Text(Localization().getStringEx("panel.onboarding2.email.label.email.text", "Email Address:"), style: TextStyle(fontFamily: Styles().fontFamilies?.bold, fontSize: 18, color: Styles().colors!.fillColorPrimary),)
                ),)],),
                
                Padding(padding: EdgeInsets.only(bottom: 12), child:
                  Semantics(textField: true, excludeSemantics: true,
                    label: Localization().getStringEx("panel.onboarding2.email.label.email.text", "Email Address:"),
                    hint: Localization().getStringEx("panel.onboarding2.email.label.email.hint", ""),
                    value: _emailController.text,
                    child: Container(
                      color: Styles().colors?.background,
                      child: TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        autofocus: false,
                        autocorrect: false,
                        enabled: false,
                        style: TextStyle(fontSize: 18, fontFamily: Styles().fontFamilies?.regular, color: Styles().colors?.textBackground),
                        decoration: textFeildDecoration,
                      ),
                    ),
                  ),
                ),

                Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(bottom: 6), child:
                  Text(Localization().getStringEx("panel.onboarding2.email.label.password.text", "Password:"), style: TextStyle(fontFamily: Styles().fontFamilies?.bold, fontSize: 18, color: Styles().colors!.fillColorPrimary),)
                ),)],),
                
                Semantics(textField: true, excludeSemantics: true, 
                  label: Localization().getStringEx("panel.onboarding2.email.label.password.text", "Password:"),
                  hint: Localization().getStringEx("panel.onboarding2.email.label.password.hint", ""),
                  value: _passwordController.text,
                  child: Container(
                    color: Styles().colors?.white,
                    child: TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      autofocus: false,
                      autocorrect: false,
                      obscureText: !_isShowingPassword,
                      onSubmitted: (_) => _clearErrorMsg,
                      cursorColor: Styles().colors?.textBackground,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18, fontFamily: Styles().fontFamilies?.regular, color: Styles().colors?.textBackground),
                      decoration: textFeildDecoration,
                    ),
                  ),
                ),

                Visibility(visible: (_state == Auth2EmailAccountState.nonExistent), child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Row(children: [ Expanded(child: Padding(padding: EdgeInsets.only(top: 12, bottom: 6), child:
                      Text(Localization().getStringEx("panel.onboarding2.email.label.confirm_password.text", "Confirm Password:"), style: TextStyle(fontFamily: Styles().fontFamilies?.bold, fontSize: 18, color: Styles().colors!.fillColorPrimary),)
                    ),)],),

                    Semantics(textField: true, excludeSemantics: true,
                      label: Localization().getStringEx("panel.onboarding2.email.label.confirm_password.text", "Confirm Password:"),
                      hint: Localization().getStringEx("panel.onboarding2.email.label.confirm_password.hint", ""),
                      value: _confirmPasswordController.text,
                      child: Container(
                        color: Styles().colors?.white,
                        child: TextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          autofocus: false,
                          autocorrect: false,
                          obscureText: !_isShowingPassword,
                          onSubmitted: (_) => _clearErrorMsg,
                          cursorColor: Styles().colors?.textBackground,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 18, fontFamily: Styles().fontFamilies?.regular, color: Styles().colors?.textBackground),
                          decoration: textFeildDecoration,
                        ),
                      ),
                    ),
                  ],)
                ),

                Row(children: [
                  
                  Expanded(child:
                    AppSemantics.buildCheckBoxSemantics( selected: _isShowingPassword, title: showPassword,
                      child: InkWell(onTap: () => _onTapShowPassword(), child:
                        Padding(padding: EdgeInsets.only(top: 12, bottom: 12), child:
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(_isShowingPassword ? 'images/deselected-dark.png' : 'images/deselected.png', excludeFromSemantics: true,),
                            Container(width: 6),
                            Text(showPassword, textAlign: TextAlign.left, style: TextStyle(fontSize: 16, color: Styles().colors!.fillColorPrimary, fontFamily: Styles().fontFamilies!.bold),),
                          ],)
                        ),
                      ),
                    ),
                  ),

                  Visibility(visible: (_state != Auth2EmailAccountState.nonExistent), child:
                    Expanded(child: 
                      Padding(padding: EdgeInsets.only(left: 12), child:
                        InkWell(onTap: () => (_state == Auth2EmailAccountState.unverified) ? _onTapResendEmail() : _onTapForgotPassword(), child:
                          Padding(padding: EdgeInsets.only(top: 12, bottom: 12), child:
                            //Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: [
                              (_state == Auth2EmailAccountState.unverified)  ?
                                Text(Localization().getStringEx("panel.onboarding2.email.label.resend_email.text", "Resend Verification"), textAlign: TextAlign.right, style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontFamily: Styles().fontFamilies!.bold, decoration: TextDecoration.underline),) :
                                Text(Localization().getStringEx("panel.onboarding2.email.label.forgot_password.text", "Forgot Password?"), textAlign: TextAlign.right, style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontFamily: Styles().fontFamilies!.bold, decoration: TextDecoration.underline),),
                            //],)
                          ),
                        ),
                      ),
                    ),
                  ),
                ],),

                Visibility(visible: StringUtils.isNotEmpty(_validationErrorText), child:
                  Padding(key:_validationErrorKey, padding: EdgeInsets.only(bottom: 12), child:
                    Text(StringUtils.ensureNotEmpty(_validationErrorText ?? ''), style: TextStyle(color: _validationErrorColor ?? Styles().colors!.fillColorSecondary, fontSize: 16, fontFamily: Styles().fontFamilies!.bold),),
                  ),
                ),

                Container(height: 24,),
                
                Padding(padding: EdgeInsets.only(bottom: 8), child: RoundedButton(
                  label:  buttonTitle,
                  hint: buttonHint,
                  onTap: _onTapLogin,
                  backgroundColor: Styles().colors?.white,
                  textColor: Styles().colors?.fillColorPrimary,
                  borderColor: Styles().colors?.fillColorSecondary,
                  progress: _isSiging,
                ),),
                
                Visibility(visible: (widget.link == true), child:
                  Padding(padding: EdgeInsets.only(bottom: 8), child: RoundedButton(
                    label:  Localization().getStringEx("panel.onboarding2.email.button.link.cancel.label", "Cancel"),
                    hint: Localization().getStringEx("panel.onboarding2.email.button.link.cancel.hint", ""),
                    onTap: _onTapCancel,
                    backgroundColor: Styles().colors?.white,
                    textColor: Styles().colors?.fillColorPrimary,
                    borderColor: Styles().colors?.fillColorSecondary,
                    progress: _isCanceling,
                  ),),
                ),

              ]),
            ),
          ),
        ),
        Container(height: 16,)
      ],),
      backgroundColor: Styles().colors?.background,
      bottomNavigationBar: uiuc.TabBar(),
    );
  }

  void _onTapShowPassword() {
    setState(() {
      _isShowingPassword = !_isShowingPassword;
      AppSemantics.announceCheckBoxStateChange(context, _isShowingPassword, "Show Password");
    });
  }

  void _onTapForgotPassword() {
    Analytics().logSelect(target: "Forgot Password");

    if (_isSiging != true) {
      _clearErrorMsg();

      setState(() { _isSiging = true; });

      Auth2().resetEmailPassword(widget.email).then((result) {
        
        if (mounted) {
          setState(() { _isSiging = false; });
          
          if (result == Auth2EmailForgotPasswordResult.succeeded) {
            _emailFocusNode.unfocus();
            _passwordFocusNode.unfocus();
            _confirmPasswordFocusNode.unfocus();
            _passwordController.text = '';
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.forgot_password.succeeded.text", "A password reset link had been sent to your email address. Please reset your password and then try to login."), color: _successColor);
            setState(() {
              _isShowingPassword = false;
            });
          } else if (result == Auth2EmailForgotPasswordResult.failedActivationExpired) {
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.forgot_password.failed.activation_expired.text", "Your activation link has already expired. A verification email has been resent to your email address. Please confirm it in order to activate your account."));
          } else if (result == Auth2EmailForgotPasswordResult.failedNotActivated) {
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.forgot_password.failed.not_activated.text", "Your account is not activated yet. Please confirm the email sent to your email address."));
          } else {
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.forgot_password.failed.text", "Failed to send password reset email. An unexpected error occurred."));
          }
        }
      });
    }
  }

  void _onTapResendEmail() {
    Analytics().logSelect(target: "Resend Email");

    if (_isSiging != true) {
      _clearErrorMsg();

      setState(() { _isSiging = true; });

      Auth2().resentActivationEmail(widget.email).then((bool result) {

        if (mounted) {
          setState(() { _isSiging = false; });
          
          if (result == true) {
            _emailFocusNode.unfocus();
            _passwordFocusNode.unfocus();
            _confirmPasswordFocusNode.unfocus();
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.resend_email.succeeded.text", "Verification email has been resent."), color: _successColor);
            setState(() {
              _isShowingPassword = false;
            });
          }
          else {
            setErrorMsg(Localization().getStringEx("panel.onboarding2.email.resend_email.failed.text", "Failed to resend verification email."));
          }
        }
      });
    }
  }

  void _onTapLogin() {
    if (_state == Auth2EmailAccountState.nonExistent) {
      _trySignUp();
    }
    else {
      _trySignIn();
    }
  }

  void _trySignUp() {
    Analytics().logSelect(target: "Sign Up");

    if (_isSiging != true) {
      _clearErrorMsg();

      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      String strengthRegEx = r'^(?=(.*[a-z]){1,})(?=(.*[A-Z]){1,})(?=(.*[0-9]){1,})(?=(.*[!@#$%^&*()\-__+.]){1,}).{8,}$';
      if (password.isEmpty) {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.validation.password_empty.text", "Please enter your password."));
      }
      else if (!RegExp(strengthRegEx).hasMatch(password)) {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.validation.password_weak.text", "Password must be at least 8 characters long and must contain a lowercase letter, uppercase letter, number, and a special character."));
      }
      else if (password != confirmPassword) {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.validation.passwords_dont_match.text", "Passwords do not match."));
      }
      else {
        setState(() { _isSiging = true; });

        if (widget.link != true) {
          Auth2().signUpWithEmail(widget.email, password).then((Auth2EmailSignUpResult result) {
            _trySignUpCallback(result);
          });
        } else {
          Map<String, dynamic> creds = {
            "email": widget.email,
            "password": password
          };
          Map<String, dynamic> params = {
            "sign_up": true,
            "confirm_password": confirmPassword
          };
          Auth2().linkAccountAuthType(Auth2LoginType.email, creds, params).then((result) {
            _trySignUpCallback(auth2EmailSignUpResultFromAuth2LinkResult(result));
          });
        }
      }
    }
  }

  void _trySignUpCallback(Auth2EmailSignUpResult result) {
    if (mounted) {
      setState(() { _isSiging = false; });

      if (result == Auth2EmailSignUpResult.succeeded) {
        _emailFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        setState(() {
          _state = Auth2EmailAccountState.unverified;
          _isShowingPassword = false;
        });
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_up.succeeded.text", "A verification email has been sent to your email address. To activate your account you need to confirm it. Then you will be able to login with your new credential."), color: _successColor);
      }
      else if (result == Auth2EmailSignUpResult.failedAccountExist) {
        setState(() {
          _state = Auth2EmailAccountState.unverified;
          _isShowingPassword = false;
        });
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_up.failed.account_exists.text", "Sign up failed. An existing account is already using this email address."));
      }
      else /*if (result == Auth2EmailSignUpResult.failed)*/ {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_up.failed.text", "Sign up failed. An unexpected error occurred."));
      }
    }
  }

  void _trySignIn() {
    Analytics().logSelect(target: "Sign In");

    if (_isSiging != true) {
      _clearErrorMsg();

      String password = _passwordController.text;

      if (password.isEmpty) {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.validation.password_empty.text", "Please enter your password."));
      }
      else {
        setState(() { _isSiging = true; });

        if (widget.link != true) {        
          Auth2().authenticateWithEmail(widget.email, password).then((Auth2EmailSignInResult result) {
            _trySignInCallback(result);
          });
        } else {
          Map<String, dynamic> creds = {
            "email": widget.email,
            "password": password
          };
          Map<String, dynamic> params = {};
          Auth2().linkAccountAuthType(Auth2LoginType.email, creds, params).then((Auth2LinkResult result) {
            _trySignInCallback(auth2EmailSignInResultFromAuth2LinkResult(result));
          });
        }
      }
    }
  }
  
  void _trySignInCallback(Auth2EmailSignInResult result) {
    if (mounted) {
      setState(() { _isSiging = false; });

      if (result == Auth2EmailSignInResult.failed) {
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_in.failed.text", "Sign in failed. An unexpected error occurred."));
      }
      else if (result == Auth2EmailSignInResult.failedNotActivated) {
        setState(() {
          _state = Auth2EmailAccountState.unverified;
        });
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_in.failed.not_activated.text", "Your account is not activated yet. Please confirm the email sent to your email address."));
      }
      else if (result == Auth2EmailSignInResult.failedActivationExpired) {
        setState(() {
          _state = Auth2EmailAccountState.unverified;
        });
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_in.failed.activation_expired.text", "Your activation link has already expired. Please resend verification email again and confirm it in order to activate your account."));
      }
      else if (result == Auth2EmailSignInResult.failedInvalid) {
        setState(() {
          _state = Auth2EmailAccountState.verified;
        });
        setErrorMsg(Localization().getStringEx("panel.onboarding2.email.sign_in.failed.invalid.text", "Incorrect password."));
      }
      else if (widget.onFinish != null) {
        widget.onFinish!();
      }
    }
  }

  void _onTapCancel() {
    setState(() { _isCanceling = true; });

    for (Auth2Type authType in Auth2().linkedEmail) {
      if (authType.identifier == widget.email) {
        Auth2().unlinkAccountAuthType(Auth2LoginType.email, widget.email!).then((success) {
          if(mounted) {
            setState(() {
              _isCanceling = false;
            });
            if (!success) {
              setState(() {
                setErrorMsg(Localization().getStringEx("panel.onboarding2.email.link.cancel.text", "Failed to remove email address from your account."));
              });
            }
            else if (widget.onFinish != null) {
              widget.onFinish!();
            }
          }
        });
        return;
      }
    }

    if (widget.onFinish != null) {
      widget.onFinish!();
    }
  }

  void setErrorMsg(String? msg, { Color? color}) {
    setState(() {
      _validationErrorText = msg;
      _validationErrorColor = color ?? _errorColor;
    });

    if (StringUtils.isNotEmpty(msg)) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (_validationErrorKey.currentContext != null) {
          Scrollable.ensureVisible(_validationErrorKey.currentContext!, duration: Duration(milliseconds: 300)).then((_) {
          });
        }
      });
    }
  }

  void _clearErrorMsg() {
    setState(() {
      _validationErrorText = null;
    });
  }
}