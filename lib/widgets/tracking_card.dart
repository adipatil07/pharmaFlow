import 'package:flutter/material.dart';

class TrackingCard extends StatelessWidget {
  final String trackingId;
  final String status;
  final int currentStep;
  final bool hasHospitalStep;

  const TrackingCard({
    super.key,
    required this.trackingId,
    required this.status,
    required this.currentStep,
    this.hasHospitalStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: Colors.green,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Text(
        //     status,
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 10),
        // Text(
        //   trackingId,
        //   style: const TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //   ),
        // ),
        // const SizedBox(height: 16),
        _buildStepFlow(deviceSize),
      ],
    );
  }

  Widget _buildStepFlow(double deviceSize) {
    List<String> steps = hasHospitalStep
        ? ["Manufacturer", "Transporter", "Pharma Store", "Hospital", "Patient"]
        : ["Manufacturer", "Transporter", "Pharma Store", "Patient"];

    return Column(
      children: [
        Wrap(
          spacing: deviceSize * 0.02,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(steps.length, (index) {
            bool isCompleted = index < currentStep;
            bool isCurrentStep = index == currentStep;
            bool isNextStep = index == currentStep + 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  Container(
                    height: 2,
                    width: 40,
                    color: isCompleted
                        ? Colors.green // Completed path
                        : isCurrentStep
                            ? Colors.blue // Current progress
                            : isNextStep
                                ? Colors.orange // Next step path
                                : Colors.grey, // Not started
                  ),
                _buildStep(
                    steps, index, isCompleted, isCurrentStep, isNextStep),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStep(List<String> steps, int index, bool isCompleted,
      bool isCurrentStep, bool isNextStep) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green // Completed step
                : isCurrentStep
                    ? Colors.blue // Current step in progress
                    : isNextStep
                        ? Colors.orange // Next step (to be done soon)
                        : Colors.grey, // Future steps
            border: Border.all(color: Colors.black54, width: 1.5),
          ),
          child: isCompleted
              ? const Icon(Icons.check,
                  color: Colors.white, size: 18) // ✅ Completed
              : isCurrentStep
                  ? const Icon(Icons.directions_run,
                      color: Colors.white, size: 18) // 🏃 Current Step
                  : isNextStep
                      ? const Icon(Icons.access_time,
                          color: Colors.white,
                          size: 18) // ⏳ Next step indicator
                      : null,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            steps[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCompleted || isCurrentStep ? Colors.black : Colors.grey,
              fontSize: 14,
              fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
