import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:porcamanage/customers/colors.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isUploadingImage = false;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    try {
      final profile = await firestoreService.getUserProfile();

      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone;
        });
      } else {
        final user = authService.currentUser;
        if (user != null) {
          final defaultProfile = UserProfile(
            id: user.uid,
            name: user.displayName ?? 'Utilisateur',
            email: user.email ?? '',
            phone: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await firestoreService.createUserProfile(defaultProfile);
          setState(() {
            _userProfile = defaultProfile;
            _nameController.text = defaultProfile.name;
            _emailController.text = defaultProfile.email;
            _phoneController.text = defaultProfile.phone;
          });
        }
      }
    } catch (e) {
      print('Erreur chargement profil: $e');
      _showErrorSnackbar('Erreur lors du chargement du profil');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);

        final updatedProfile = UserProfile(
          id: _userProfile!.id,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          profilePicture: _userProfile?.profilePicture,
          createdAt: _userProfile!.createdAt,
          updatedAt: DateTime.now(),
        );

        await firestoreService.updateUserProfile(updatedProfile);

        setState(() {
          _userProfile = updatedProfile;
          _isEditing = false;
        });

        _showSuccessSnackbar('Profil mis à jour avec succès');
      } catch (e) {
        print('Erreur sauvegarde profil: $e');
        _showErrorSnackbar('Erreur lors de la sauvegarde');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer la photo de profil'),
        content: Text('Comment souhaitez-vous ajouter une photo ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: Text('Galerie'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhotoWithCamera();
            },
            child: Text('Appareil photo'),
          ),
          if (_userProfile?.profilePicture != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeProfilePicture();
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    _updateImageUploadState(true);

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final base64Image = await firestoreService.pickImageFromGallery();

      if (base64Image != null) {
        await firestoreService.updateProfilePicture(base64Image);
        await _loadUserData(); // Recharger les données
        _showSuccessSnackbar('Photo de profil mise à jour');
      }
    } catch (e) {
      print('Erreur galerie: $e');
      _showErrorSnackbar('Erreur lors de l\'ajout de la photo');
    } finally {
      _updateImageUploadState(false);
    }
  }

  Future<void> _takePhotoWithCamera() async {
    _updateImageUploadState(true);

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final base64Image = await firestoreService.takePhotoWithCamera();

      if (base64Image != null) {
        await firestoreService.updateProfilePicture(base64Image);
        await _loadUserData(); // Recharger les données
        _showSuccessSnackbar('Photo de profil mise à jour');
      }
    } catch (e) {
      print('Erreur caméra: $e');
      _showErrorSnackbar('Erreur lors de la prise de photo');
    } finally {
      _updateImageUploadState(false);
    }
  }

  Future<void> _removeProfilePicture() async {
    _updateImageUploadState(true);

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      await firestoreService.removeProfilePicture();
      await _loadUserData(); // Recharger les données
      _showSuccessSnackbar('Photo de profil supprimée');
    } catch (e) {
      print('Erreur suppression: $e');
      _showErrorSnackbar('Erreur lors de la suppression');
    } finally {
      _updateImageUploadState(false);
    }
  }

  void _updateImageUploadState(bool uploading) {
    if (mounted) {
      setState(() {
        _isUploadingImage = uploading;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isUploadingImage) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.grey[300],
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[700]!),
          ),
        ),
      );
    }

    if (_userProfile?.profilePicture != null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: ClipOval(
          child: Image.memory(
            base64Decode(_userProfile!.profilePicture!),
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          ),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        gradient: LinearGradient(
          colors: [Colors.yellow[700]!, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildPersonalInfoSection(),
            _buildStatsSection(),
            _buildSettingsSection(),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement du profil...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            Colors.yellow[500]!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: _toggleEdit,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Photo de profil avec bouton de modification
                Stack(
                  children: [
                    _buildProfileImage(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.yellow[700]!, width: 2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.yellow[700]!,
                          ),
                          onPressed: _isUploadingImage ? null : _showImageSourceDialog,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  _nameController.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _emailController.text,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Membre depuis ${_formatDate(_userProfile?.createdAt ?? DateTime.now())}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.yellow[700]),
                SizedBox(width: 10),
                Text(
                  'Informations Personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildEditableField(
              label: 'Nom Complet',
              controller: _nameController,
              icon: Icons.person,
              isEditing: _isEditing,
            ),
            SizedBox(height: 15),
            _buildEditableField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email,
              isEditing: _isEditing,
              isEmail: true,
            ),
            SizedBox(height: 15),
            _buildEditableField(
              label: 'Téléphone',
              controller: _phoneController,
              icon: Icons.phone,
              isEditing: _isEditing,
              isPhone: true,
            ),
            if (_isEditing) ...[
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEdit,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text('Sauvegarder'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 10),
          Expanded(
            child: isEditing
                ? TextFormField(
              controller: controller,
              style: (isEditing && isEmail) ? TextStyle(fontSize: 16,color: Colors.grey.shade500) : TextStyle(),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: (isEditing && isEmail) ? TextStyle(color: Colors.red):TextStyle(),
              ),
              readOnly: isEmail,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                if (!_isValidPhone(value)) {
                  return 'Numéro de téléphone invalide';
                }
                return null;
              },
            )
                : Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                controller.text.isEmpty ? 'Non renseigné' : controller.text,
                style: TextStyle(fontSize: 16,),
              ),
            ),
          ),
        ],
      ),
    );
  }
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
    return phoneRegex.hasMatch(phone);
  }

  Widget _buildStatsSection() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: Provider.of<FirestoreService>(context).getUserStatsSimple(), // ← Utilisez getUserStatsSimple()
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatsLoading();
        }

        if (snapshot.hasError) {
          return _buildStatsError();
        }

        final stats = snapshot.data ?? {
          'totalTransactions': 0,
          'totalDebts': 0,
          'totalSavings': '0',
        };

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Transactions',
                  value: '${stats['totalTransactions']}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Dettes',
                  value: '${stats['totalDebts']}',
                  icon: Icons.credit_card,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Économies',
                  value: '${stats['totalSavings']}',
                  icon: Icons.savings,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCardSkeleton()),
          SizedBox(width: 10),
          Expanded(child: _buildStatCardSkeleton()),
          SizedBox(width: 10),
          Expanded(child: _buildStatCardSkeleton()),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: Colors.grey[400], size: 20),
          ),
          SizedBox(height: 10),
          Container(
            width: 30,
            height: 20,
            color: Colors.grey[300],
          ),
          SizedBox(height: 5),
          Container(
            width: 50,
            height: 12,
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsError() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Erreur de chargement des statistiques',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.yellow[700]),
              SizedBox(width: 10),
              Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            onTap: () => _showComingSoon(),
          ),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Sécurité',
            subtitle: 'Mot de passe, authentification',
            onTap: () => _showComingSoon(),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Langue',
            subtitle: 'Français',
            onTap: () => _showComingSoon(),
          ),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Mode Sombre',
            subtitle: 'Activer/Désactiver',
            trailing: Switch(value: false, onChanged: (value) {}),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.yellow[700]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.yellow[700]),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 5),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            onTap: () => _showComingSoon(),
          ),
          _buildActionButton(
            icon: Icons.share,
            title: 'Partager l\'application',
            onTap: _shareApp,
          ),
          _buildActionButton(
            icon: Icons.star_outline,
            title: 'Noter l\'application',
            onTap: () => _showComingSoon(),
          ),
          _buildActionButton(
            icon: Icons.exit_to_app,
            title: 'Déconnexion',
            onTap: _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isLogout ? Colors.red[50] : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.yellow[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité à venir!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareApp() {
    // Implémentation du partage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de l\'application!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
              } catch (e) {
                _showErrorSnackbar('Erreur lors de la déconnexion');
              }
            },
            child: Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}