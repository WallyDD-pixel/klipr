import 'package:flutter/material.dart';
import 'package:app/screens/tiktok_login_page.dart';

/// Page de profil utilisateur
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _autoplayEnabled = false;
  bool _qualityAutoAdjust = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header de profil
              _buildProfileHeader(),
              
              const SizedBox(height: 24),
              
              // Statistiques
              _buildStatsSection(),
              
              const SizedBox(height: 32),
              
              // Paramètres
              _buildSettingsSection(),
              
              const SizedBox(height: 32),
              
              // Actions
              _buildActionsSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nom d'utilisateur
          Text(
            'KliprUser',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            'Membre depuis octobre 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton éditer profil
          ElevatedButton(
            onPressed: () {
              // Éditer le profil
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Éditer le profil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Clips sauvés', '12', Icons.bookmark),
          _buildStatDivider(),
          _buildStatItem('Heures regardées', '48h', Icons.play_circle),
          _buildStatDivider(),
          _buildStatItem('Créateurs suivis', '8', Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6366F1),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Recevoir des alertes pour les lives',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        
        _buildSettingsTile(
          icon: Icons.play_arrow_outlined,
          title: 'Lecture automatique',
          subtitle: 'Lancer automatiquement les vidéos',
          trailing: Switch(
            value: _autoplayEnabled,
            onChanged: (value) => setState(() => _autoplayEnabled = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        
        _buildSettingsTile(
          icon: Icons.hd_outlined,
          title: 'Qualité adaptative',
          subtitle: 'Ajuster la qualité selon la connexion',
          trailing: Switch(
            value: _qualityAutoAdjust,
            onChanged: (value) => setState(() => _qualityAutoAdjust = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ),
        
        _buildSettingsTile(
          icon: Icons.language_outlined,
          title: 'Langue',
          subtitle: 'Français',
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
          onTap: () {
            // Changer la langue
          },
        ),
        
        _buildSettingsTile(
          icon: Icons.palette_outlined,
          title: 'Thème',
          subtitle: 'Sombre',
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
          onTap: () {
            // Changer le thème
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF6366F1),
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Informations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildActionTile(
          icon: Icons.help_outline_rounded,
          title: 'Centre d\'aide',
          subtitle: 'Questions fréquentes et support',
          onTap: () {
            // Ouvrir l'aide
          },
        ),
        
        _buildActionTile(
          icon: Icons.info_outline_rounded,
          title: 'À propos de Klipr',
          subtitle: 'Version 1.0.0',
          onTap: () {
            // Afficher les informations de l'app
          },
        ),
        
        _buildActionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Politique de confidentialité',
          subtitle: 'Protection de vos données',
          onTap: () {
            // Ouvrir la politique
          },
        ),
        
        _buildActionTile(
          icon: Icons.description_outlined,
          title: 'Conditions d\'utilisation',
          subtitle: 'Termes et conditions',
          onTap: () {
            // Ouvrir les CGU
          },
        ),
        
        const SizedBox(height: 24),
        
        // Bouton de déconnexion
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TikTokLoginPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Se déconnecter',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: Colors.grey[400],
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[500],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}