import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/review_service.dart';

class AddReviewPage extends StatefulWidget {
  final int productId;
  const AddReviewPage({super.key, required this.productId});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _reviewController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false; // To disable the button
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Whether voice input is currently active

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize the speech recognition instance
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      // Called when the listening status changes
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      //Called if there's an error
      onError: (error) => setState(() => _isListening = false),
    );

    // If microphone access is allowed
    if (available) {
      setState(() => _isListening = true);
      // Begin listening and update text field with recognized words
      _speech.listen(onResult: (result) {
        setState(() {
          _reviewController.text = result.recognizedWords;
          _reviewController.selection = TextSelection.fromPosition(
            TextPosition(offset: _reviewController.text.length),
          );
        });
      });
    }
  }

  // Stop listening to voice input
  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  //Submit the review
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your review before submitting.")), //To prevent empty submissions
      );
      return;
    }

    setState(() => _isSubmitting = true); // Show loading state

    final success = await ReviewService.submitReview( //Calls submitReview function in Review Service
      widget.productId,
      _rating,
      _reviewController.text.trim(),
    );

    setState(() => _isSubmitting = false); // Stop loading

    if (!mounted) return;
    // Show a success or failure snackbar message
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit review. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;

    final ratingStars = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) { //Generates a list of 5 stars
        return IconButton(
          iconSize: 28, 
          icon: Icon(
            index < _rating ? Icons.star_rounded : Icons.star_border_rounded, 
            color: Colors.amber.shade600,
          ),
          onPressed: () => setState(() => _rating = index + 1), //Changes the rating based on the number of stars selected (index of the start list)
        );
      }),
    );

    final reviewInput = TextField(
      controller: _reviewController,
      maxLines: 5,
      style: const TextStyle(fontSize: 14), 
      decoration: InputDecoration(
        hintText: "Write your detailed review here...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );

    final microphoneButton = Center(
      child: IconButton(
        iconSize: 36,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.grey),
        onPressed: _isListening ? _stopListening : _startListening,
      ),
    );

    final submitButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReview, // Disable button while being submitted
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _isSubmitting ? "Submitting..." : "Submit Review", //Changes the text of the button accordingly
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    final content = [
      Text(
        "Rate this product",
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      ratingStars,
      const SizedBox(height: 16),
      Text(
        "Your Review",
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      reviewInput,
      const SizedBox(height: 10),
      microphoneButton,
      const SizedBox(height: 20),
      submitButton,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Add Review")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (orientation == Orientation.landscape) { //If orientation is lanscape,
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left side: product icon
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review, size: 70, color: Colors.teal),
                        const SizedBox(height: 16),
                        Text(
                          "PROGEAR",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  //Right side: review form
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: content,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView( //If orientation is portrait
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(Icons.rate_review, size: 70, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "PROGEAR",
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...content,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
