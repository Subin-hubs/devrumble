import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/MarketAPI.dart';




class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() {
    return _MarketState();
  }
}

class _MarketState extends State<Market> {
  static const Color darkGreen = Color(0xFF174F30);
  static const Color lightGreen = Color(0xFFEAF6EE);

  late Future<List<MarketPrice>> priceRequest;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    priceRequest = MarketApi.getPrices();
  }

  Future<void> refreshPrices() async {
    final newRequest = MarketApi.getPrices();

    setState(() {
      priceRequest = newRequest;
    });

    await newRequest;
  }

  void tryAgain() {
    setState(() {
      priceRequest = MarketApi.getPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: FutureBuilder<List<MarketPrice>>(
              future: priceRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: darkGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return buildErrorScreen(
                    snapshot.error.toString(),
                  );
                }

                final List<MarketPrice> allPrices =
                    snapshot.data ?? [];

                final String query =
                searchQuery.toLowerCase().trim();

                final List<MarketPrice> filteredPrices =
                allPrices.where((item) {
                  return item.name
                      .toLowerCase()
                      .contains(query);
                }).toList();

                return RefreshIndicator(
                  color: darkGreen,
                  onRefresh: refreshPrices,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      17,
                      12,
                      30,
                    ),
                    children: [
                      buildSearchBox(),
                      const SizedBox(height: 14),

                      if (filteredPrices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Center(
                            child: Text(
                              'No matching crop found.',
                            ),
                          ),
                        )
                      else
                        ...filteredPrices.map(
                          buildPriceCard,
                        ),

                      if (filteredPrices.isNotEmpty)
                        buildMarketInsight(
                          filteredPrices.first,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14,
        MediaQuery.paddingOf(context).top + 14,
        14,
        22,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Prices',
                    style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'बजार मूल्य',
                    style: TextStyle(
                      color: Color(0xFF70C890),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Color(0xFF71CC92),
                  size: 18,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Kalimati, Kathmandu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF71CC92),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'Live wholesale data · Source: Kalimati Market',
              style: TextStyle(
                color: Color(0xFF72A985),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search tomato, potato, काउली...',
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPriceCard(MarketPrice item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              getCropInitial(item.name),
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lora(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rs ${formatMoney(item.minimum)} – '
                      'Rs ${formatMoney(item.maximum)}',
                  style: const TextStyle(
                    color: Color(0xFF789384),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${formatMoney(item.average)}',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'per ${item.unit}',
                style: const TextStyle(
                  color: Color(0xFF73907F),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget buildMarketInsight(MarketPrice item) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF1),
        border: Border.all(
          color: const Color(0xFFF1B64B),
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Text(
        '💡  Market Insight\n\n'
            '${item.name} ranges from '
            'Rs ${formatMoney(item.minimum)} to '
            'Rs ${formatMoney(item.maximum)} '
            'per ${item.unit}. Today’s official average is '
            'Rs ${formatMoney(item.average)}.',
        style: GoogleFonts.lora(
          fontSize: 12,
          height: 1.45,
          color: const Color(0xFF80531A),
        ),
      ),
    );
  }

  Widget buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Color(0xFF8AA497),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load market prices',
              style: GoogleFonts.lora(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: tryAgain,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  String formatMoney(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(2);
  }

  String getCropInitial(String name) {
    if (name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }
}