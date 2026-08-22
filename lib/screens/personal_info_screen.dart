import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/resume.dart';
import '../state/resume_provider.dart';

/// Feature #4: Personal Information (fields + show/hide options) and
/// feature #30: Image Handling (pick / crop-free resize / remove).
class PersonalInfoScreen extends StatefulWidget {
  final Resume resume;
  const PersonalInfoScreen({super.key, required this.resume});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late PersonalInfo info;
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    info = widget.resume.personalInfo;
    for (final f in _fields) {
      _controllers[f.$1] = TextEditingController(text: f.$3(info));
    }
  }

  // (key, label, getter, setter)
  List<(String, String, String Function(PersonalInfo), void Function(PersonalInfo, String))>
      get _fields => [
            ('fullName', 'Full Name', (i) => i.fullName, (i, v) => i.fullName = v),
            ('jobTitle', 'Job Title', (i) => i.jobTitle, (i, v) => i.jobTitle = v),
            ('phone', 'Phone Number', (i) => i.phone, (i, v) => i.phone = v),
            ('email', 'Email', (i) => i.email, (i, v) => i.email = v),
            ('address', 'Address', (i) => i.address, (i, v) => i.address = v),
            ('city', 'City', (i) => i.city, (i, v) => i.city = v),
            ('state', 'State/Province', (i) => i.state, (i, v) => i.state = v),
            ('country', 'Country', (i) => i.country, (i, v) => i.country = v),
            ('zip', 'ZIP/Postal Code', (i) => i.zip, (i, v) => i.zip = v),
            ('website', 'Website', (i) => i.website, (i, v) => i.website = v),
            ('linkedin', 'LinkedIn', (i) => i.linkedin, (i, v) => i.linkedin = v),
            ('github', 'GitHub', (i) => i.github, (i, v) => i.github = v),
            ('portfolio', 'Portfolio', (i) => i.portfolio, (i, v) => i.portfolio = v),
            ('otherLink', 'Other Social/Profile Link', (i) => i.otherLink, (i, v) => i.otherLink = v),
          ];

  void _onChanged(String key, String value) {
    final field = _fields.firstWhere((f) => f.$1 == key);
    field.$4(info, value);
    context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (file == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/photo_${const Uuid().v4()}.jpg';
    await File(file.path).copy(destPath);
    setState(() => info.photoPath = destPath);
    context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
  }

  void _removePhoto() {
    setState(() => info.photoPath = '');
    context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: info.photoPath.isNotEmpty && File(info.photoPath).existsSync()
                        ? FileImage(File(info.photoPath))
                        : null,
                    child: info.photoPath.isEmpty
                        ? const Icon(Icons.add_a_photo_outlined, size: 28, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Select Photo'),
                    ),
                    if (info.photoPath.isNotEmpty)
                      TextButton.icon(
                        onPressed: _removePhoto,
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final f in _fields) ...[
            TextField(
              controller: _controllers[f.$1],
              decoration: InputDecoration(labelText: f.$2),
              keyboardType: f.$1 == 'email'
                  ? TextInputType.emailAddress
                  : f.$1 == 'phone'
                      ? TextInputType.phone
                      : TextInputType.text,
              onChanged: (v) => _onChanged(f.$1, v),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(height: 32),
          Text('Display Options', style: Theme.of(context).textTheme.titleSmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Photo'),
            value: info.showPhoto,
            onChanged: (v) {
              setState(() => info.showPhoto = v);
              context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Address'),
            value: info.showAddress,
            onChanged: (v) {
              setState(() => info.showAddress = v);
              context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Social Links'),
            value: info.showSocialLinks,
            onChanged: (v) {
              setState(() => info.showSocialLinks = v);
              context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
