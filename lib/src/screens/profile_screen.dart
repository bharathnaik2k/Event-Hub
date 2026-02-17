import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/src/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? user;
  String appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(uid).get();
      log(userSnapshot.toString());
      log(uid.toString());

      if (userSnapshot.exists) {
        user = userSnapshot.data() as Map<String, dynamic>?;
        log('User loaded: ${user?['displayName']}');
      } else {
        log('User document does not exist');
      }
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (e) {
      log('Error loading profile: $e');
    }
    setState(() {});
  }

  final String imageKitPrivateKey = 'private_ae77ulwzJ7elp9WNxF1rsq28kCs=';
  final String imageKitUploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';

  Future<void> pickAndUploadDirect() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 15,
    );

    if (pickedFile == null) {
      return;
    }
    final file = File(pickedFile.path);
    final request = http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['fileName'] = file.path.split('/').last;
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$imageKitPrivateKey:'))}';
    request.headers['Authorization'] = basicAuth;

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(respStr);
      final url = jsonResponse['url'];
      log('image URL: $url');
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'photoURL': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('Name updated successfully');
    } else {
      log('(${response.statusCode}): $respStr');
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    // Try to launch the URL in an external app (browser)
    final launched = await launchUrl(
      uri,
      // mode: LaunchMode.externalApplication, // <- forces external browser/app
    );

    if (!launched) {
      // Fallback or show error
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            InkWell(
              borderRadius: BorderRadius.circular(60),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child:
                        user?['photoURL'] == null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                            : ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user!['photoURL'],
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                  ),
                  GestureDetector(
                    onTap: pickAndUploadDirect,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(153, 255, 255, 255),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Color.fromARGB(255, 103, 58, 183),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?['displayName'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                if (user?['displayName'] != null)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/updateNameScreen');
                    },
                    child: Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 204, 174, 255),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user?['email'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            if (user?['userinterest'] != null &&
                (user!['userinterest'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children:
                      (user!['userinterest'] as List).map<Widget>((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(70, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(147, 255, 255, 255),
                            ),
                          ),
                          child: Text(
                            interest.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildMenuItem(
                      icon: Icons.event,
                      title: 'My Events',
                      onTap: () {
                        Navigator.of(context).pushNamed('/myEventScreen');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.of(context).pushNamed('/helpAndSupport');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        _openUrl(
                          'https://sites.google.com/view/event-hub-app/privacy-policy',
                        );
                      },
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(53, 155, 39, 176),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      title: Text(
                        'App version :  v$appVersion',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          OAuthService().signOut(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryPurple,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(53, 155, 39, 176),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
