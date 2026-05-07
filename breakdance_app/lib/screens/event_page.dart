// ==============================================================
// FICHIER : lib/screens/event_page.dart
// ROLE    : Liste des events — clic ouvre la page detail
// VERSION : 6
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../widgets/app_theme.dart';
import 'event_detail_page.dart';

class EventPage extends StatelessWidget {
  final List<EventModel> events;
  final UserModel? currentUser;

  const EventPage({super.key, required this.events, this.currentUser});

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    const m = ['', 'jan', 'fev', 'mar', 'avr', 'mai', 'jun', 'jul', 'aou', 'sep', 'oct', 'nov', 'dec'];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('EVENTS', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text('${events.length} event${events.length > 1 ? "s" : ""}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: events.isEmpty ? _buildEtatVide() : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: events.length,
        itemBuilder: (_, i) => _carteEvent(context, events[i]),
      ),
    );
  }

  Widget _buildEtatVide() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 90, height: 90,
        decoration: BoxDecoration(color: const Color(0xFFE9C46A).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE9C46A).withOpacity(0.3))),
        child: const Icon(Icons.event, color: Color(0xFFE9C46A), size: 40)),
      const SizedBox(height: 20),
      const Text('AUCUN EVENT', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 8),
      const Text('Les events s\'inscrivent avec un compte Event.\nIls apparaissent ici automatiquement !', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
    ]));
  }

  Widget _carteEvent(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EventDetailPage(event: event, currentUser: currentUser),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(width: double.infinity, height: 150,
              child: event.photoPath != null
                  ? Image.file(File(event.photoPath!), fit: BoxFit.cover)
                  : Container(color: const Color(0xFFE9C46A).withOpacity(0.08),
                      child: const Center(child: Icon(Icons.event, color: Color(0xFFE9C46A), size: 48)))),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.nom, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text(event.ville, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (event.dateEvent != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 13),
                  const SizedBox(width: 4),
                  Text(_formatDate(event.dateEvent), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ]),
              if (event.flyers.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 13),
                  const SizedBox(width: 4),
                  Text('${event.flyers.length} flyer${event.flyers.length > 1 ? "s" : ""}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
