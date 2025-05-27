import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infi_social/models/user_model.dart';
import 'package:infi_social/services/auth_service.dart';
import 'package:infi_social/services/storage_service.dart';
import 'package:infi_social/widgets/text_field_widget.dart';
import 'package:infi_social/utils/functions/pick_image.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  UserModel? currentUser;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  late String selectedGender;
  late String avatarUrl;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<AuthService>(context, listen: false).user;

    _firstNameController =
        TextEditingController(text: currentUser?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: currentUser?.lastName ?? '');
    _usernameController =
        TextEditingController(text: currentUser?.username ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _bioController = TextEditingController(text: currentUser?.bio ?? '');
    _ageController = TextEditingController(text: currentUser?.age ?? '');
    avatarUrl = currentUser?.avatarUrl ?? '';
    selectedGender = currentUser?.gender ?? 'other';
  }

  Future<void> _pickImage() async {
    _image = await pickImage(isCamera: false);
    if (_image != null) {
      String _avatarUrl = await uploadOnCloudinary(_image!.path);
      if (_avatarUrl != '') {
        setState(() {
          avatarUrl = _avatarUrl;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No image selected"),
        ),
      );
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
          ),
        );
        return;
      }

      final updatedData = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "bio": _bioController.text.trim(),
        "age": _ageController.text.trim(),
        "gender": selectedGender,
        "avatarUrl": avatarUrl,
      };

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final updatedUser = await authService.updateUser(
        userId: userId,
        updateData: updatedData,
      );

      Navigator.of(context).pop();

      if (updatedUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null
                      ? FileImage(File(_image!.path))
                      : avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : const AssetImage('assets/avatar.png'),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      hintText: "Enter First Name",
                      labelText: "First Name",
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: "Last Name",
                      hintText: "Enter Last Name",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _usernameController,
                labelText: "Username",
                hintText: "Enter username",
                validator: (value) =>
                    value!.isEmpty ? "Username can't be empty" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      labelText: "Age",
                      hintText: "Enter age",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Age can't be empty";
                        }
                        final age = int.tryParse(value.trim());
                        if (age == null) {
                          return "Please enter a valid number";
                        } else if (age <= 0) {
                          return "Age must be greater than 0";
                        } else if (age > 120) {
                          return "Enter a valid age (1-120)";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedGender,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(8),
                      hint: const Text('Select Gender'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: Gender.values
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender.name,
                              child: Text(
                                gender.name.toUpperCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!.toString();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                enabled: false,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email can't be empty";
                  } else if (!value
                      .contains(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'))) {
                    return 'Please enter a vaild email address';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.save),
                  label: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
