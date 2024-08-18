import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/screens/sign_in_sign_up/sign_in_sign_up_widget.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../../controllers/users/create_profile_model.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final SizedBox spacer = const SizedBox(height: kPadding4);
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CreateProfileModel>();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: GradientAppBar(
        useBorder: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInSignUpPage()));
          },
        ),

        title: const Center(
          child: Text(
            'Create Profile', //TODO: Center
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: FormField<String>(
                      onSaved: (newValue) => model.validateProfilePicture(),
                        builder: (formState) {
                          return GestureDetector(
                            onTap: () => model.pickImage(formState),
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: <Widget>[
                                    Container(
                                      height: 160,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: model.profileImage != null
                                              ? FileImage(model.profileImage!)
                                              : const AssetImage(
                                                      'assets/images/UI_avatar@2x.png')
                                                  as ImageProvider<Object>,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child:
                                          Icon(Icons.add_a_photo, color: Colors.white70),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text('Tap to change profile picture'),
                                ),
                                if (formState.hasError)
                                   Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    formState.errorText ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: kErrorColor),
                                  ),
                                  ),
                              ],
                            ),
                          );
                        },
                        validator: (value) => model.validateProfilePicture(),
                    ),
                  ),
                  spacer,
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 5.0, // Adjust the elevation as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextFormField(
                      autofillHints: const [AutofillHints.givenName],
                      controller: model.firstNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  spacer,

                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 5.0, // Adjust the elevation as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextFormField(
                      autofillHints: const [AutofillHints.familyName],
                      controller: model.surnameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Surname',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  spacer,

                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 7.0, // Adjust the elevation as needed
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          borderOnForeground: false,
                          child: TextField(
                            readOnly: true,
                            controller: model.dateOfBirthController,
                            onTap: () => model.pickDate(context),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              hintText: 'Age',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: kPadding4),
                      Expanded(
                        flex: 12,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: model.gender,
                            items: <String>[
                              'Male',
                              'Female',
                              'Non-Binary',
                              'Trans-male',
                              'Trans-Female',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              model.setGender(newValue);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Gender',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  spacer,
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 5.0, // Adjust the elevation as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: model.relationshipStatus,
                      items: <String>[
                        'Single',
                        'Married',
                        'Open relationship',
                        'In a relationship',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        model.setRelationshipStatus(newValue);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Relationship Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  spacer,
                  Row(
                    children: [
                      Expanded(
                        child: MirrorElevatedButton(
                          onPressed: () =>
                              model.saveProfileAndNavigate(context, _formKey),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  spacer,

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/Asset_3@10x.png',
                      width: 100,
                      height: 85,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
