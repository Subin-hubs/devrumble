import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class MarketPrice {
  const MarketPrice({
    required this.name,
    required this.unit,
    required this.minimum,
    required this.maximum,
    required this.average,
  });

  final String name;
  final String unit;
  final double minimum;
  final double maximum;
  final double average;
}

class MarketApi {
  static const String sourceUrl =
      'https://kalimatimarket.gov.np/price';

  static Future<List<MarketPrice>> getPrices() async {
    final response = await http.get(
      Uri.parse(sourceUrl),
      headers: const {
        'Accept': 'text/html,application/xhtml+xml',
        'User-Agent': 'Mozilla/5.0 Agrova/1.0',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Kalimati server returned ${response.statusCode}',
      );
    }

    final document = html_parser.parse(response.body);

    final List<MarketPrice> prices = [];

    final rows = document.querySelectorAll('table tr');

    for (final row in rows) {
      final cells = row.querySelectorAll('td');

      if (cells.length < 5) {
        continue;
      }

      final String name = cells[0].text.trim();
      final String unit = cells[1].text.trim();

      final double? minimum = _convertNumber(cells[2].text);
      final double? maximum = _convertNumber(cells[3].text);
      final double? average = _convertNumber(cells[4].text);

      if (name.isEmpty ||
          minimum == null ||
          maximum == null ||
          average == null) {
        continue;
      }

      prices.add(
        MarketPrice(
          name: name,
          unit: unit,
          minimum: minimum,
          maximum: maximum,
          average: average,
        ),
      );
    }

    if (prices.isEmpty) {
      throw Exception(
        'No prices were found. The official website format may have changed.',
      );
    }

    return prices;
  }

  static double? _convertNumber(String input) {
    const String nepaliDigits = '०१२३४५६७८९';

    String value = input;

    for (int i = 0; i < nepaliDigits.length; i++) {
      value = value.replaceAll(
        nepaliDigits[i],
        i.toString(),
      );
    }

    value = value.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );

    return double.tryParse(value);
  }
}