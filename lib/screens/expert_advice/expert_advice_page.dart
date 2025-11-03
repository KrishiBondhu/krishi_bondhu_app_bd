import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/problem_repository.dart';

class ExpertAdvicePage extends StatefulWidget {
  const ExpertAdvicePage({super.key});

  @override
  State<ExpertAdvicePage> createState() => _ExpertAdvicePageState();
}

class _ExpertAdvicePageState extends State<ExpertAdvicePage> {
  @override
  Widget build(BuildContext context) {
    // Tabs: Submit, Pending, Expert Responses, Call
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expert Advice'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.report_problem), text: 'Submit Problem'),
              Tab(icon: Icon(Icons.pending_actions), text: 'Pending Responses'),
              Tab(icon: Icon(Icons.verified_user), text: 'Expert Responses'),
              Tab(icon: Icon(Icons.call), text: 'Call'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProblemForm(),
            _PendingProblems(),
            _ExpertResponses(),
            _CallTab(),
          ],
        ),
      ),
    );
  }
}

class _ProblemForm extends StatefulWidget {
  const _ProblemForm();

  @override
  State<_ProblemForm> createState() => _ProblemFormState();
}

class _ProblemFormState extends State<_ProblemForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  bool _urgent = false;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    ProblemRepository.instance.ensureInitialized();
  }

  @override
  void dispose() {
    _cropController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Use Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 2048,
    );
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final problem = Problem(
      id: const Uuid().v4(),
      cropName: _cropController.text.trim(),
      description: _descriptionController.text.trim(),
      // Category removed from UI; set a default internally
      category: 'General',
      urgent: _urgent,
      imagePath: _image?.path,
      createdAt: DateTime.now(),
    );

    await ProblemRepository.instance.submit(problem);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Problem submitted.')),
    );

    // Clear form
    setState(() {
      _cropController.clear();
      _descriptionController.clear();
      _urgent = false;
      _image = null;
    });

    // Go to Pending tab
    DefaultTabController.of(context)?.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Submit Query / Problem Report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Crop name
            TextFormField(
              controller: _cropController,
              decoration: const InputDecoration(
                labelText: 'Crop name',
                hintText: 'e.g., Rice, Wheat, Tomato',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter crop name' : null,
            ),
            const SizedBox(height: spacing),

            // Description
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the problem in detail',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter description' : null,
            ),
            const SizedBox(height: spacing),

            // Urgent toggle
            SwitchListTile(
              value: _urgent,
              title: const Text('Mark as urgent'),
              onChanged: (v) => setState(() => _urgent = v),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: spacing),

            // Optional image picker
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Photo (optional)'),
                ),
                const SizedBox(width: 12),
                if (_image != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_image!.path),
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: spacing * 1.5),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingProblems extends StatefulWidget {
  const _PendingProblems();

  @override
  State<_PendingProblems> createState() => _PendingProblemsState();
}

class _PendingProblemsState extends State<_PendingProblems> {
  @override
  void initState() {
    super.initState();
    ProblemRepository.instance.ensureInitialized();
    ProblemRepository.instance.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    ProblemRepository.instance.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() => setState(() {});

  Future<void> _showDetails(Problem p) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final responseController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.cropName} • ${p.category}',
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (p.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                  ),
                const SizedBox(height: 8),
                Text(p.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Chip(
                      label: Text(p.urgent ? 'Urgent' : 'Normal'),
                      avatar: Icon(
                          p.urgent ? Icons.priority_high : Icons.schedule,
                          size: 18),
                    ),
                    const Spacer(),
                    Text(
                      'Submitted: ${p.createdAt.toLocal()}'.split('.').first,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Add expert response',
                    style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: responseController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type expert answer...',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (val) async {
                    await _markAnswered(p, val);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final resp = responseController.text.trim();
                      if (resp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a response first.'),
                          ),
                        );
                        return;
                      }
                      await _markAnswered(p, resp);
                      if (ctx.mounted) Navigator.of(ctx).pop(); // close sheet
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as answered'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAnswered(Problem p, String response) async {
    if (response.trim().isEmpty) return;
    await ProblemRepository.instance
        .markAnswered(id: p.id, response: response.trim());
    if (!mounted) return;
    // Switch to Expert Responses tab
    DefaultTabController.of(context)?.animateTo(2);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moved to Expert Responses.')));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProblemRepository.instance;
    final items = repo.pending;

    return RefreshIndicator(
      onRefresh: () async {
        await repo.ensureInitialized();
        setState(() {});
      },
      child: items.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 60),
                Center(
                    child: Text(
                        'No pending problems. Submit one to get started.')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = items[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(p.cropName.isNotEmpty
                          ? p.cropName[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(p.cropName),
                    subtitle: Text('${p.category} • ${p.description}',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (p.urgent)
                          const Icon(Icons.priority_high, color: Colors.red),
                        const SizedBox(height: 4),
                        Text(
                          timeLabel(p.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () => _showDetails(p),
                  ),
                );
              },
            ),
    );
  }
}

class _ExpertResponses extends StatefulWidget {
  const _ExpertResponses();

  @override
  State<_ExpertResponses> createState() => _ExpertResponsesState();
}

class _ExpertResponsesState extends State<_ExpertResponses> {
  @override
  void initState() {
    super.initState();
    ProblemRepository.instance.ensureInitialized();
    ProblemRepository.instance.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    ProblemRepository.instance.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final repo = ProblemRepository.instance;
    final items = repo.answered;

    return items.isEmpty
        ? ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 60),
              Center(child: Text('No expert responses yet.')),
            ],
          )
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = items[i];
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.verified),
                  title: Text('${p.cropName} • ${p.category}'),
                  subtitle: Text(
                      'Submitted: ${timeLabel(p.createdAt)} • Answered: ${timeLabel(p.respondedAt ?? DateTime.now())}'),
                  children: [
                    if (p.imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              Image.file(File(p.imagePath!), fit: BoxFit.cover),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your description:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(p.description),
                          const SizedBox(height: 12),
                          const Text('Expert response:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(p.expertResponse ?? '—'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
  }
}

class _CallTab extends StatelessWidget {
  const _CallTab();

  // Set your helpline number here
  static const String _helplineNumber = '+8801705500372';

  Future<void> _makeCall(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _helplineNumber);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to make call')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _makeCall(context),
            customBorder: const CircleBorder(),
            child: Ink(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.call,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tap to call expert',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _helplineNumber,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String timeLabel(DateTime dt) {
  final now = DateTime.now();
  Duration diff = now.difference(dt);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
