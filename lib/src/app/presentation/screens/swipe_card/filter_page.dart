import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/filter_page_model.dart';

class FilterPage extends StatefulWidget {
  final String userId;

  const FilterPage({required this.userId, super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late FilterPageModel model;

  @override
  void initState() {
    super.initState();
    model = Provider.of<FilterPageModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilterPageModel>(
      create: (_) => FilterPageModel(userId: widget.userId)
        ..retrieveFiltersFromFirestore(),
      child: Consumer<FilterPageModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: GradientAppBar(
              title: const Text('Filters'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    model.saveFiltersToFirestore().then((value) {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<FilterPageModel>(context, listen: false)
                            .clearFilters();
                        const snackBar =
                            SnackBar(content: Text('Filters cleared!'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: const Text('Clear Filters'),
                    ),
                    checkboxWithFilter(
                      context,
                      'Distance',
                      CheckboxListTile(
                        title: const Text('Distance'),
                        value: model.checkboxValues['Distance'],
                        onChanged: (value) {
                          model.toggleCheckbox('Distance');
                        },
                      ),
                      Slider(
                        value: model.maxDistance,
                        onChanged: (model.checkboxValues['Distance'] ?? false)
                            ? (value) {
                                model.maxDistance = value;
                              }
                            : null,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '${model.maxDistance} km',
                      ),
                    ),
                    checkboxWithFilter(
                      context,
                      'Age Range',
                      CheckboxListTile(
                        title: const Text('Age Range'),
                        value: model.checkboxValues['Age Range'],
                        onChanged: (value) {
                          model.toggleCheckbox('Age Range');
                        },
                      ),
                      RangeSlider(
                        values: model.ageRange,
                        onChanged: (model.checkboxValues['Age Range'] ?? false)
                            ? (values) {
                                model.ageRange = values;
                              }
                            : null,
                        min: 18,
                        max: 100,
                        divisions: 82,
                        labels: RangeLabels(
                          '${model.ageRange.start.round()}',
                          '${model.ageRange.end.round()}',
                        ),
                      ),
                    ),
                    checkboxWithFilter(
                      context,
                      'Gender',
                      CheckboxListTile(
                        title: const Text('Gender'),
                        value: model.checkboxValues['Gender'],
                        onChanged: (value) {
                          model.toggleCheckbox('Gender');
                        },
                      ),
                      buildDropdownWithChips(
                        context,
                        'Gender',
                        model.genderOptions,
                        model.currentGender,
                        model.selectedGenders,
                      ),
                    ),
                    checkboxWithFilter(
                      context,
                      'Looking For',
                      CheckboxListTile(
                        title: const Text('Looking For'),
                        value: model.checkboxValues['Looking For'],
                        onChanged: (value) {
                          model.toggleCheckbox('Looking For');
                        },
                      ),
                      buildDropdownWithChips(
                        context,
                        'Looking For',
                        model.lookingForOptions,
                        model.currentLookingFor,
                        model.selectedLookingFor,
                      ),
                    ),
                    checkboxWithFilter(
                      context,
                      'Orientation',
                      CheckboxListTile(
                        title: const Text('Orientation'),
                        value: model.checkboxValues['Orientation'],
                        onChanged: (value) {
                          model.toggleCheckbox('Orientation');
                        },
                      ),
                      buildDropdownWithChips(
                        context,
                        'Orientation',
                        model.orientationOptions,
                        model.currentOrientation,
                        model.selectedOrientations,
                      ),
                    ),
                    checkboxWithFilter(
                      context,
                      'Religion',
                      CheckboxListTile(
                        title: const Text('Religion'),
                        value: model.checkboxValues['Religion'],
                        onChanged: (value) {
                          model.toggleCheckbox('Religion');
                        },
                      ),
                      buildDropdownWithChips(
                        context,
                        'Religion',
                        model.religionOptions,
                        model.currentReligion,
                        model.selectedReligions,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Interests'),
                    checkboxWithFilter(
                      context,
                      'Interests',
                      CheckboxListTile(
                        title: const Text('Interests'),
                        value: model.checkboxValues['Interests'],
                        onChanged: (value) {
                          model.toggleCheckbox('Interests');
                        },
                      ),
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: model.allInterests.map((interest) {
                          return FilterChip(
                            label: Text(interest),
                            selected: model.interests.contains(interest),
                            onSelected: (model.checkboxValues['Interests'] ??
                                    false) // Checking if the checkbox for interests is checked
                                ? (bool selected) {
                                    if (selected) {
                                      model.addInterest(interest);
                                    } else {
                                      model.removeInterest(interest);
                                    }
                                  }
                                : null, // Making onSelected null if the checkbox is unchecked
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                model.isloading == true
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox(),
              ],
            ));
      }),
    );
  }

  Widget checkboxWithFilter(
    BuildContext context,
    String key,
    Widget checkbox,
    Widget filterWidget,
  ) {
    return Column(
      children: [
        checkbox,
        filterWidget,
      ],
    );
  }

  Widget buildDropdownWithChips(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    List<String> selectedOptions,
  ) {
    final model = Provider.of<FilterPageModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        DropdownButton<String>(
          value: currentValue,
          hint: Text('Select $title'),
          onChanged: (model.checkboxValues[title] ?? false)
              ? (String? newValue) {
                  if (newValue != null && !selectedOptions.contains(newValue)) {
                    model.addOption(title, newValue);
                  }
                }
              : null,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: selectedOptions.map((option) {
            return Chip(
              label: Text(option),
              onDeleted: () {
                model.removeOption(title, option);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/*@override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilterPageModel>(
      create: (_) => FilterPageModel(userId: widget.userId)
        ..retrieveFiltersFromFirestore(),
      child: Consumer<FilterPageModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: GradientAppBar(
              title: const Text('Filters'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    await model.saveFiltersToFirestore();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<FilterPageModel>(context, listen: false)
                        .clearFilters();
                    const snackBar =
                        SnackBar(content: Text('Filters cleared!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Clear Filters'),
                ),
                checkboxWithFilter(
                  context,
                  'Distance',
                  CheckboxListTile(
                    title: const Text('Distance'),
                    value: model.checkboxValues['Distance'],
                    onChanged: (value) {
                      model.toggleCheckbox('Distance');
                    },
                  ),
                  Slider(
                    value: model.maxDistance,
                    onChanged: (model.checkboxValues['Distance'] ?? false)
                        ? (value) {
                            model.maxDistance = value;
                          }
                        : null,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${model.maxDistance} km',
                  ),
                ),
                checkboxWithFilter(
                  context,
                  'Age Range',
                  CheckboxListTile(
                    title: const Text('Age Range'),
                    value: model.checkboxValues['Age Range'],
                    onChanged: (value) {
                      model.toggleCheckbox('Age Range');
                    },
                  ),
                  RangeSlider(
                    values: model.ageRange,
                    onChanged: (model.checkboxValues['Age Range'] ?? false)
                        ? (values) {
                            model.ageRange = values;
                          }
                        : null,
                    min: 18,
                    max: 100,
                    divisions: 82,
                    labels: RangeLabels(
                      '${model.ageRange.start.round()}',
                      '${model.ageRange.end.round()}',
                    ),
                  ),
                ),
                checkboxWithFilter(
                  context,
                  'Gender',
                  CheckboxListTile(
                    title: const Text('Gender'),
                    value: model.checkboxValues['Gender'],
                    onChanged: (value) {
                      model.toggleCheckbox('Gender');
                    },
                  ),
                  buildDropdownWithChips(
                    context,
                    'Gender',
                    model.genderOptions,
                    model.currentGender,
                    model.selectedGenders,
                  ),
                ),
                checkboxWithFilter(
                  context,
                  'Looking For',
                  CheckboxListTile(
                    title: const Text('Looking For'),
                    value: model.checkboxValues['Looking For'],
                    onChanged: (value) {
                      model.toggleCheckbox('Looking For');
                    },
                  ),
                  buildDropdownWithChips(
                    context,
                    'Looking For',
                    model.lookingForOptions,
                    model.currentLookingFor,
                    model.selectedLookingFor,
                  ),
                ),
                checkboxWithFilter(
                  context,
                  'Orientation',
                  CheckboxListTile(
                    title: const Text('Orientation'),
                    value: model.checkboxValues['Orientation'],
                    onChanged: (value) {
                      model.toggleCheckbox('Orientation');
                    },
                  ),
                  buildDropdownWithChips(
                    context,
                    'Orientation',
                    model.orientationOptions,
                    model.currentOrientation,
                    model.selectedOrientations,
                  ),
                ),
                checkboxWithFilter(
                  context,
                  'Religion',
                  CheckboxListTile(
                    title: const Text('Religion'),
                    value: model.checkboxValues['Religion'],
                    onChanged: (value) {
                      model.toggleCheckbox('Religion');
                    },
                  ),
                  buildDropdownWithChips(
                    context,
                    'Religion',
                    model.religionOptions,
                    model.currentReligion,
                    model.selectedReligions,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Interests'),
                checkboxWithFilter(
                  context,
                  'Interests',
                  CheckboxListTile(
                    title: const Text('Interests'),
                    value: model.checkboxValues['Interests'],
                    onChanged: (value) {
                      model.toggleCheckbox('Interests');
                    },
                  ),
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    children: model.allInterests.map((interest) {
                      return FilterChip(
                        label: Text(interest),
                        selected: model.interests.contains(interest),
                        onSelected: (model.checkboxValues['Interests'] ??
                                false) // Checking if the checkbox for interests is checked
                            ? (bool selected) {
                                if (selected) {
                                  model.addInterest(interest);
                                } else {
                                  model.removeInterest(interest);
                                }
                              }
                            : null, // Making onSelected null if the checkbox is unchecked
                      );
                    }).toList(),
                  ),
                ),
              ],
            ));
      }),
    );
  }

  Widget checkboxWithFilter(
    BuildContext context,
    String key,
    Widget checkbox,
    Widget filterWidget,
  ) {
    return Column(
      children: [
        checkbox,
        filterWidget,
      ],
    );
  }

  Widget buildDropdownWithChips(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    List<String> selectedOptions,
  ) {
    final model = Provider.of<FilterPageModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        DropdownButton<String>(
          value: currentValue,
          hint: Text('Select $title'),
          onChanged: (model.checkboxValues[title] ?? false)
              ? (String? newValue) {
                  if (newValue != null && !selectedOptions.contains(newValue)) {
                    model.addOption(title, newValue);
                  }
                }
              : null,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: selectedOptions.map((option) {
            return Chip(
              label: Text(option),
              onDeleted: () {
                model.removeOption(title, option);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}*/
