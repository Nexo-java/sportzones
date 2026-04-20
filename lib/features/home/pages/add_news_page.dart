import 'package:flutter/material.dart';

import '../models/news_model.dart';

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({
    super.key,
    this.initialNews,
    this.pageTitle = 'Create News',
    this.headerTitle = 'Publish New Story',
    this.headerSubtitle = 'Fill in the details below to add a new headline to SportZone.',
    this.submitButtonText = 'Publish News',
  });

  final NewsModel? initialNews;
  final String pageTitle;
  final String headerTitle;
  final String headerSubtitle;
  final String submitButtonText;

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage>
  with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _entryFadeAnimation;
  late final Animation<Offset> _entrySlideAnimation;

  static const _bg = Color(0xFF09092D);
  static const _panel = Color(0xFF1A1A40);
  static const _panelBorder = Color(0xFF2A2A55);
  static const _inputFill = Color(0xFF22224D);
  static const _accent = Color(0xFFFECF06);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategory;

  static const List<String> _categories = [
    'Badminton',
    'Soccer',
    'Basketball',
    'Volly',
    'Tennis',
  ];

  String _normalizeImageUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed;

    // Convert common Google Drive share links into direct-view links.
    if (uri.host.contains('drive.google.com')) {
      final idFromQuery = uri.queryParameters['id'];
      if (idFromQuery != null && idFromQuery.isNotEmpty) {
        return 'https://drive.google.com/uc?export=view&id=$idFromQuery';
      }

      final segments = uri.pathSegments;
      final fileIndex = segments.indexOf('d');
      if (fileIndex != -1 && fileIndex + 1 < segments.length) {
        final fileId = segments[fileIndex + 1];
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    // Convert Dropbox shared link into raw image link.
    if (uri.host.contains('dropbox.com')) {
      final updatedQuery = Map<String, String>.from(uri.queryParameters)
        ..['raw'] = '1';
      return uri.replace(queryParameters: updatedQuery).toString();
    }

    return trimmed;
  }

  bool _isValidImageUrl(String rawUrl) {
    final normalized = _normalizeImageUrl(rawUrl);
    final uri = Uri.tryParse(normalized);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final initialNews = widget.initialNews;
    if (initialNews != null) {
      _titleController.text = initialNews.title;
      _dateController.text = initialNews.date;
      _authorController.text = initialNews.createdBy;
      _descriptionController.text = initialNews.description;
      _imageUrlController.text = initialNews.imageUrl;
      _selectedCategory = _categories.contains(initialNews.category)
          ? initialNews.category
          : null;
    } else {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();
      _dateController.text = '$day/$month/$year';
      _authorController.text = 'Admin';
    }

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    final curve = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);
    _entrySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(curve);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final selectedCategory = _selectedCategory;
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category is required')),
      );
      return;
    }

    final now = DateTime.now();
    final initialNews = widget.initialNews;
    final normalizedImageUrl = _normalizeImageUrl(_imageUrlController.text.trim());

    final news = NewsModel(
      title: _titleController.text.trim(),
      category: selectedCategory,
      date: _dateController.text.trim(),
      createdBy: _authorController.text.trim().isEmpty
          ? 'Admin'
          : _authorController.text.trim(),
      createdAt: initialNews?.createdAt ?? now,
      updatedAt: now,
      description: _descriptionController.text.trim(),
      imageUrl: normalizedImageUrl,
    );

    Navigator.pop(context, news);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    final day = selected.day.toString().padLeft(2, '0');
    final month = selected.month.toString().padLeft(2, '0');
    final year = selected.year.toString();
    setState(() {
      _dateController.text = '$day/$month/$year';
    });
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8F8FB2), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFACAFD8), size: 20),
      filled: true,
      fillColor: _inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _panelBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.pageTitle,
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _entryFadeAnimation,
          child: SlideTransition(
            position: _entrySlideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.headerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.headerSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      decoration: BoxDecoration(
                        color: _panel.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _panelBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _fieldLabel('News Title'),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Enter a strong headline',
                              icon: Icons.title_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Category'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            dropdownColor: _panel,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Select category',
                              icon: Icons.category_rounded,
                            ),
                            iconEnabledColor: Colors.white,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Category is required' : null,
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Publish Date'),
                          TextFormField(
                            controller: _dateController,
                            style: const TextStyle(color: Colors.white),
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: _inputDecoration(
                              'Choose date',
                              icon: Icons.calendar_today_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Date is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Author / Created By'),
                          TextFormField(
                            controller: _authorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Admin',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Description'),
                          TextFormField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 4,
                            decoration: _inputDecoration(
                              'Write short summary or details',
                              icon: Icons.notes_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Image URL'),
                          TextFormField(
                            controller: _imageUrlController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.url,
                            decoration: _inputDecoration(
                              'https://example.com/image.jpg',
                              icon: Icons.link_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Image URL is required';
                              }
                              if (!_isValidImageUrl(value)) {
                                return 'Use a valid image link (http/https)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFECF06), Color(0xFFE7BA00)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: const Color(0xFF1A1A40),
                                shadowColor: Colors.transparent,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.publish_rounded),
                              label: Text(
                                widget.submitButtonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
