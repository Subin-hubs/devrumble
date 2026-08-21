import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisResultScreen({
    super.key,
    required this.result,
  });

  static const Color darkGreen = Color(0xFF14432A);
  static const Color midGreen = Color(0xFF2E7D4F);
  static const Color paleGreenBg = Color(0xFFEFF5EC);
  static const Color checkGreen = Color(0xFF3E8E5A);
  static const Color warningOrange = Color(0xFFB5651D);

  String _getString(String key, [String fallback = 'Unknown']) {
    final value = result[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  List<String> _getList(String key) {
    final value = result[key];

    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'moderate':
        return warningOrange;
      case 'low':
        return checkGreen;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _conditionIcon(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('healthy')) {
      return Icons.check_circle_outline;
    }

    if (value.contains('pest')) {
      return Icons.bug_report_outlined;
    }

    if (value.contains('deficiency')) {
      return Icons.warning_amber_rounded;
    }

    return Icons.local_florist_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final crop = _getString('crop');
    final condition = _getString('condition');
    final confidence = _getString('confidence', '0');
    final severity = _getString('severity');
    final description = _getString('description', 'No description available.');
    final recommendations = _getList('recommendations');
    final prevention = _getList('prevention');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: darkGreen,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Analysis',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(
                crop: crop,
                condition: condition,
                severity: severity,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                crop: crop,
                condition: condition,
                confidence: confidence,
                severity: severity,
              ),
              const SizedBox(height: 16),
              _buildDescriptionCard(description),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildRecommendationsCard(recommendations),
              ],
              if (prevention.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPreventionCard(prevention),
              ],
              const SizedBox(height: 24),
              _buildScanAgainButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String crop,
    required String condition,
    required String severity,
  }) {
    final isHealthy = condition.toLowerCase().contains('healthy');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: paleGreenBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_outline
                  : _conditionIcon(condition),
              size: 38,
              color: isHealthy
                  ? checkGreen
                  : _severityColor(severity),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Analysis Complete',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            crop,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String crop,
    required String condition,
    required String confidence,
    required String severity,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnosis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            icon: Icons.local_florist_outlined,
            title: 'Crop',
            value: crop,
          ),
          const Divider(height: 22),
          _buildInfoRow(
            icon: Icons.health_and_safety_outlined,
            title: 'Condition',
            value: condition,
          ),
          const Divider(height: 22),
          _buildInfoRow(
            icon: Icons.analytics_outlined,
            title: 'Confidence',
            value: '$confidence%',
          ),
          const Divider(height: 22),
          _buildInfoRow(
            icon: Icons.warning_amber_rounded,
            title: 'Severity',
            value: severity,
            valueColor: _severityColor(severity),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: darkGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'What we found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: midGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(
            recommendations.length,
                (index) => _buildBulletItem(
              recommendations[index],
              Icons.check_circle,
              checkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionCard(List<String> prevention) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: midGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Prevention',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(
            prevention.length,
                (index) => _buildBulletItem(
              prevention[index],
              Icons.shield_outlined,
              midGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(
      String text,
      IconData icon,
      Color iconColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: paleGreenBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: midGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.camera_alt_outlined,
          size: 21,
        ),
        label: const Text(
          'Scan Another Crop',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: midGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}