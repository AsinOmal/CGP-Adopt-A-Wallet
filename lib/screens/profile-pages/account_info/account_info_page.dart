import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/user.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:financial_app/components/clickble_textfield.dart';
import 'package:financial_app/components/input_field.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  late AuthBloc _authBloc;
  late AuthRepository _authRepository;

  String name = '';
  String? url;
  User? user;

  @override
  void initState() {
    super.initState();
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _authBloc = RepositoryProvider.of<AuthBloc>(context);
    _authBloc.add(AuthInfoFetching(userID: _authRepository.userID));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _selectGender(String value) {
    setState(() {
      genderController.text = value;
    });
  }

  void _showGenderPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text('Male'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectGender('Male');
                  },
                ),
                ListTile(
                  title: const Text('Female'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectGender('Female');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('my_profile'),
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return current is AuthInfoLoading ||
              current is AuthInfoSuccess ||
              current is AuthInfoError ||
              current is AuthUpdateError ||
              current is AuthUpdateLoading ||
              current is AuthUpdateSuccess;
        },
        listener: (context, state) {
          if (state is AuthInfoLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              },
            );
          }
          if (state is AuthInfoSuccess) {
            Navigator.pop(context);
            user = state.user;
            nameController.text = state.user.name;
            emailController.text = state.user.email;
            phoneController.text = state.user.phoneNumber;
            genderController.text = state.user.gender;
            birthdateController.text = state.user.birthDate;
            setState(() {
              name = state.user.name;
              url = state.user.profileImageURL;
            });
          }
          if (state is AuthUpdateLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              },
            );
          }
          if (state is AuthUpdateSuccess) {
            Navigator.pop(context);
            CustomSnackBar.showSuccessSnackBar('User details updated', context);
          }
          if (state is AuthUpdateError) {
            Navigator.pop(context);
            CustomSnackBar.showErrorSnackBar(
                'User details update error!', context);
          }
          if (state is AuthInfoError) {
            Navigator.pop(context);
            CustomSnackBar.showErrorSnackBar(
                'User details fetching error!', context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 80,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : NetworkImage(
                                    url ??
                                        'https://wlujgctqyxyyegjttlce.supabase.co/storage/v1/object/public/users_propics/users_propics/default_img.png',
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      InputField(
                        isReadOnly: false,
                        controller: nameController,
                        isObsecure: false,
                        prefixIcon: Icons.person,
                        label: AppLocalizations.of(context).translate('name'),
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isReadOnly: true,
                        controller: emailController,
                        isObsecure: false,
                        onTap: () {
                          CustomSnackBar.showErrorSnackBar(
                              'You can\'t change the email', context);
                        },
                        label: AppLocalizations.of(context).translate('email'),
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isReadOnly: false,
                        controller: phoneController,
                        isObsecure: false,
                        label: AppLocalizations.of(context)
                            .translate('phone_number'),
                        prefixIcon: Icons.phone,
                      ),
                      const SizedBox(height: 20),
                      ClickbleTextfield(
                        label: AppLocalizations.of(context)
                            .translate('select_gender'),
                        controller: genderController,
                        onTap: _showGenderPicker,
                        prefixIcon: Icons.transgender,
                      ),
                      const SizedBox(height: 20),
                      ClickbleTextfield(
                        label: AppLocalizations.of(context)
                            .translate('select_birth_date'),
                        prefixIcon: Icons.calendar_month,
                        controller: birthdateController,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            birthdateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: 'save',
                onPressed: () async {
                  _authBloc.add(
                    AuthUpdateUser(
                      image: _image,
                      isImageChange: _image != null,
                      user: User(
                        userID: user!.userID,
                        name: nameController.text,
                        email: emailController.text,
                        createdAt: user!.createdAt,
                        phoneNumber: phoneController.text,
                        gender: genderController.text,
                        birthDate: birthdateController.text,
                        profileImageURL: url!,
                        languagePreference: user!.languagePreference,
                        currencyPreference: user!.currencyPreference,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
