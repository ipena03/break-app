// ==============================================================
// FICHIER : lib/screens/crew_page.dart
// ROLE    : Liste publique de TOUS les crews inscrits
//           Clic sur un crew -> page detail
// ==============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/combi_model.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import 'crew_detail_page.dart';

class CrewPage extends StatelessWidget {
  final List<UserModel> crews;
  final UserModel? currentUser;

  const CrewPage({super.key, required this.crews, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CREWS', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text('${crews.length} crew${crews.length > 1 ? "s" : ""}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: crews.isEmpty ? _buildEtatVide() : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: crews.length,
        itemBuilder: (_, i) => _carteCrew(context, crews[i]),
      ),
    );
  }

  Widget _buildEtatVide() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 90, height: 90,
        decoration: BoxDecoration(color: const Color(0xFF457B9D).withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF457B9D).withOpacity(0.3))),
        child: const Icon(Icons.groups, color: Color(0xFF457B9D), size: 40)),
      const SizedBox(height: 20),
      const Text('AUCUN CREW', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 8),
      const Text('Les crews s\'inscrivent avec un compte Crew.\nIls apparaissent ici automatiquement !', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
    ]));
  }

  Widget _carteCrew(BuildContext context, UserModel crew) {
    return GestureDetector(
      // Clic : ouvrir la page detail du crew
      onTap: () async {
        // On charge les combis du crew
        final combis = await StorageService().chargerCombis(crew.id);
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CrewDetailPage(crew: crew, currentUser: currentUser, combis: combis),
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            child: SizedBox(width: 90, height: 90,
              child: crew.photoPath != null
                  ? Image.file(File(crew.photoPath!), fit: BoxFit.cover)
                  : Container(color: const Color(0xFF457B9D).withOpacity(0.1), child: const Icon(Icons.groups, color: Color(0xFF457B9D), size: 36))),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(crew.pseudo, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              if (crew.pays != null && crew.pays!.isNotEmpty)
                Row(children: [
                  const Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 13),
                  const SizedBox(width: 4),
                  Text(crew.pays!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF457B9D).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF457B9D).withOpacity(0.4))),
                child: const Text('CREW', style: TextStyle(color: Color(0xFF457B9D), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ]),
          )),
          const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18)),
        ]),
      ),
    );
  }
}
