import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/ocean_dial.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/data/models/quote_viewmodel.dart';

import '../../components/gradient_appbar.dart';

class QuoteView extends StatefulWidget {
  final String userId;
  final bool isTabView;
  final bool isEditable;

  const QuoteView({
    super.key,
    required this.userId,
    this.isTabView = false,
    this.isEditable = true,
  });

  @override
  _QuoteViewState createState() => _QuoteViewState();
}

class _QuoteViewState extends State<QuoteView> {
  late QuoteViewModel _viewModel;
  Map<String, dynamic>? _oceanScores;
  Map<String, dynamic>? _rawOceanScores;
  Map<String, Map<String, String?>>? _reflectionQuotes;
  String? _mbtiType;

  @override
  void initState() {
    super.initState();
    _viewModel = QuoteViewModel(widget.userId, isEditable: widget.isEditable);
    _loadData();
  }

  _loadData() async {
    _oceanScores = await _viewModel.fetchOCEANScores();
    _rawOceanScores = await _viewModel.fetchOCEANRawScores();

    _reflectionQuotes = {};

    for (var entry in _oceanScores!.entries) {
      String traitAbbreviation = entry.key;
      String score = entry.value;

      Map<String, String?> reflectionQuotes =
          await _viewModel.fetchReflectionQuotes(traitAbbreviation, score);
      _reflectionQuotes![traitAbbreviation] = reflectionQuotes;
    }

    _mbtiType = await _viewModel.fetchMBTIType();

    setState(() {});
  }

  Widget buildBubble(
      Color color, String text, Alignment alignment, Color textColor) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: const GradientAppBar(title: Text("Insights")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 20,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const secondaryColor = kPrimaryAccentColor;
    const watchoutColor = Colors.grey;
    final List<String> oceanOrder = ['O', 'C', 'E', 'A', 'N'];
    final Map<String, Color> traitColors = {
      'O': Colors.orange,
      'C': Colors.cyan,
      'E': Colors.green,
      'A': Colors.red[400]!,
      'N': Colors.blue,
    };
    final Map<String, Color> darkerTraitColors = {
      'O': Colors.brown[800]!, // Darker shade of orange
      'C': Colors.lightBlue[900]!, // Darker shade of cyan
      'E': Colors.teal[900]!, // Darker shade of green
      'A': Colors.red[900]!, // Darker shade of red
      'N': Colors.blue[900]!, // Darker shade of blue
    };

    // Check if data is still loading or null
    if (_rawOceanScores == null ||
        _oceanScores == null ||
        _reflectionQuotes == null ||
        _mbtiType == null) {
      return _buildLoadingState(); // Show loading state if data is not ready
    } else {
      return Scaffold(
        appBar: widget.isTabView
            ? null
            : const GradientAppBar(title: Text("Know yourself")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 40),
                child: Text(
                  'MBTI Type: $_mbtiType',
                  textAlign: TextAlign.center, // Center align the text
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPurpleColor,
                  ),
                ),
                //OceanScoreDial(oceanScores: _rawOceanScores!),
              ),
              OceanScoreDial(oceanScores: _rawOceanScores!),
              const SizedBox(
                height: 40,
              ),
              ...oceanOrder.map((traitKey) {
                final score = _oceanScores![traitKey];
                final reflectionQuote = _reflectionQuotes![traitKey];
                if (score != null && reflectionQuote != null) {
                  return Card(
                    color: traitColors[traitKey],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_viewModel.traitMapping[traitKey]}: $score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkerTraitColors[traitKey] ??
                                  secondaryColor, // Access the specific darker color
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildBubble(
                              darkerTraitColors[traitKey]!,
                              'Strength:\n\n ${reflectionQuote['Strength']}',
                              Alignment.centerLeft,
                              Colors.white),
                          const SizedBox(height: 10),
                          buildBubble(
                            watchoutColor,
                            'Considerations:\n\n ${reflectionQuote['Watchout']}',
                            Alignment.centerRight,
                            darkerTraitColors[traitKey] ?? secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // For debugging
                  if (kDebugMode) {
                    print("Trait not found or null: $traitKey");
                  }
                  return const SizedBox
                      .shrink(); // Return an empty widget for non-existing traits
                }
              }),
            ],
          ),
        ),
      );
    }
  }
}
