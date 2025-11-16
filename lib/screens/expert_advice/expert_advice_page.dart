import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// MAIN ENTRY POINT - ROLE SELECTION
// ============================================================

class ExpertAdvicePage extends StatelessWidget {
  const ExpertAdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিশেষজ্ঞ পরামর্শ'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'আপনার ভূমিকা নির্বাচন করুন',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
              _RoleCard(
                icon: Icons.person,
                title: 'আমি একজন ব্যবহারকারী',
                subtitle: 'সমস্যা জমা দিন এবং বিশেষজ্ঞ পরামর্শ পান',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserDashboard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _RoleCard(
                icon: Icons.verified_user,
                title: 'আমি একজন বিশেষজ্ঞ',
                subtitle: 'ব্যবহারকারীদের প্রশ্নের উত্তর দিন',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpertLoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXPERT LOGIN
// ============================================================

class ExpertLoginPage extends StatefulWidget {
  const ExpertLoginPage({super.key});

  @override
  State<ExpertLoginPage> createState() => _ExpertLoginPageState();
}

class _ExpertLoginPageState extends State<ExpertLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ExpertAuthService.instance.ensureInitialized();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ExpertAuthService.instance.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ExpertDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বিশেষজ্ঞ লগইন')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 100, color: Colors.blue),
                const SizedBox(height: 24),
                Text(
                  'বিশেষজ্ঞ প্যানেল',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'ফোন নম্বর',
                    hintText: '01XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'ফোন নম্বর দিন';
                    if (v!.length != 11) return 'সঠিক ফোন নম্বর দিন';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'পাসওয়ার্ড',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'পাসওয়ার্ড দিন';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('লগইন', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('অ্যাকাউন্ট নেই?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpertSignupPage(),
                          ),
                        );
                      },
                      child: const Text('সাইন আপ করুন'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXPERT SIGNUP
// ============================================================

class ExpertSignupPage extends StatefulWidget {
  const ExpertSignupPage({super.key});

  @override
  State<ExpertSignupPage> createState() => _ExpertSignupPageState();
}

class _ExpertSignupPageState extends State<ExpertSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ExpertAuthService.instance.signUp(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      specialization: _specializationController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ExpertDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বিশেষজ্ঞ সাইন আপ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'নতুন বিশেষজ্ঞ নিবন্ধন',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'পুরো নাম',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'নাম দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'ফোন নম্বর',
                  hintText: '01XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'ফোন নম্বর দিন';
                  if (v!.length != 11) return 'সঠিক ফোন নম্বর দিন';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'বিশেষত্ব',
                  hintText: 'যেমন: উদ্ভিদ রোগ বিশেষজ্ঞ',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'বিশেষত্ব দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'পাসওয়ার্ড',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'পাসওয়ার্ড দিন';
                  if (v!.length < 6) return 'কমপক্ষে ৬ অক্ষর হতে হবে';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'পাসওয়ার্ড মিলছে না';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('সাইন আপ', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ইতিমধ্যে অ্যাকাউন্ট আছে?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('লগইন করুন'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FORGOT PASSWORD
// ============================================================

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ExpertAuthService.instance.resetPassword(
      phone: _phoneController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পাসওয়ার্ড রিসেট')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                Text(
                  'পাসওয়ার্ড পুনরায় সেট করুন',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'ফোন নম্বর',
                    hintText: '01XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'ফোন নম্বর দিন';
                    if (v!.length != 11) return 'সঠিক ফোন নম্বর দিন';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'নতুন পাসওয়ার্ড',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'নতুন পাসওয়ার্ড দিন';
                    if (v!.length < 6) return 'কমপক্ষে ৬ অক্ষর হতে হবে';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('পাসওয়ার্ড পরিবর্তন করুন',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// USER DASHBOARD
// ============================================================

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ব্যবহারকারী ড্যাশবোর্ড'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.report_problem), text: 'সমস্যা জমা দিন'),
              Tab(icon: Icon(Icons.pending_actions), text: 'আমার সমস্যা'),
              Tab(icon: Icon(Icons.call), text: 'কল করুন'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProblemForm(),
            _UserProblems(),
            _CallTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EXPERT DASHBOARD
// ============================================================

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> {
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('লগআউট'),
        content: const Text('আপনি কি লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ExpertAuthService.instance.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExpertLoginPage()),
        );
      }
    }
  }

  Future<void> _showProblemDetails(Problem p) async {
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
                Row(
                  children: [
                    Icon(
                      p.urgent ? Icons.priority_high : Icons.info_outline,
                      color: p.urgent ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${p.cropName} • ${p.category}',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(p.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সমস্যার বিবরণ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(p.description),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(
                        p.urgent ? Icons.priority_high : Icons.schedule,
                        size: 18,
                      ),
                      label: Text(p.urgent ? 'জরুরি' : 'সাধারণ'),
                    ),
                    Chip(
                      avatar: const Icon(Icons.access_time, size: 18),
                      label:
                          Text('জমা দেওয়া হয়েছে ${timeLabel(p.createdAt)}'),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'আপনার বিশেষজ্ঞ পরামর্শ:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: responseController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'এখানে আপনার পরামর্শ লিখুন...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final resp = responseController.text.trim();
                      if (resp.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('অনুগ্রহ করে একটি উত্তর লিখুন')),
                        );
                        return;
                      }

                      await ProblemRepository.instance.markAnswered(
                        id: p.id,
                        response: resp,
                      );

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('উত্তর পাঠানো হয়েছে!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('উত্তর পাঠান'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProblemRepository.instance;
    final expert = ExpertAuthService.instance.currentExpert;
    final allProblems = [...repo.pending, ...repo.answered];
    allProblems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('বিশেষজ্ঞ ড্যাশবোর্ড'),
            if (expert != null)
              Text(
                expert.name,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Badge(
                label: Text('${repo.pending.length}'),
                child: const Icon(Icons.notifications),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'লগআউট',
            onPressed: _logout,
          ),
        ],
      ),
      body: allProblems.isEmpty
          ? const Center(child: Text('এখনও কোনো অনুরোধ নেই'))
          : RefreshIndicator(
              onRefresh: () async {
                await repo.ensureInitialized();
                setState(() {});
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: allProblems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = allProblems[i];
                  final isAnswered = p.isAnswered;

                  return Card(
                    elevation: isAnswered ? 1 : 3,
                    color: isAnswered
                        ? Colors.grey[100]
                        : (p.urgent ? Colors.red[50] : null),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAnswered
                            ? Colors.green
                            : (p.urgent ? Colors.red : Colors.orange),
                        child: Icon(
                          isAnswered
                              ? Icons.check
                              : (p.urgent
                                  ? Icons.priority_high
                                  : Icons.help_outline),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        p.cropName,
                        style: TextStyle(
                          fontWeight:
                              isAnswered ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeLabel(p.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: isAnswered
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showProblemDetails(p),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ============================================================
// PROBLEM FORM
// ============================================================

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
              title: const Text('গ্যালারি থেকে নির্বাচন করুন'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('ক্যামেরা ব্যবহার করুন'),
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
      category: 'সাধারণ',
      urgent: _urgent,
      imagePath: _image?.path,
      createdAt: DateTime.now(),
    );

    await ProblemRepository.instance.submit(problem);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('সমস্যা সফলভাবে জমা হয়েছে!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _cropController.clear();
      _descriptionController.clear();
      _urgent = false;
      _image = null;
    });

    DefaultTabController.of(context)?.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'আপনার সমস্যা জমা দিন',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cropController,
              decoration: const InputDecoration(
                labelText: 'ফসলের নাম',
                hintText: 'যেমন: ধান, গম, টমেটো',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco),
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'ফসলের নাম দিন' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'সমস্যার বিবরণ',
                hintText: 'বিস্তারিতভাবে সমস্যা লিখুন...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'সমস্যার বিবরণ দিন' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _urgent,
              title: const Text('জরুরি হিসেবে চিহ্নিত করুন'),
              subtitle: const Text('অগ্রাধিকার উত্তর পান'),
              secondary: const Icon(Icons.priority_high),
              onChanged: (v) => setState(() => _urgent = v),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('ছবি যুক্ত করুন (ঐচ্ছিক)'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_image!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('সমস্যা জমা দিন'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// USER PROBLEMS
// ============================================================

class _UserProblems extends StatefulWidget {
  const _UserProblems();

  @override
  State<_UserProblems> createState() => _UserProblemsState();
}

class _UserProblemsState extends State<_UserProblems> {
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
    final allProblems = [...repo.pending, ...repo.answered];
    allProblems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allProblems.isEmpty
        ? const Center(child: Text('এখনও কোনো সমস্যা জমা দেওয়া হয়নি'))
        : RefreshIndicator(
            onRefresh: () async {
              await repo.ensureInitialized();
              setState(() {});
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: allProblems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = allProblems[i];
                return Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          p.isAnswered ? Colors.green : Colors.orange,
                      child: Icon(
                        p.isAnswered ? Icons.check : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(p.cropName),
                    subtitle: Text(
                      p.isAnswered
                          ? 'বিশেষজ্ঞ উত্তর দিয়েছেন ${timeLabel(p.respondedAt!)}'
                          : 'উত্তরের জন্য অপেক্ষা করুন • ${timeLabel(p.createdAt)}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.imagePath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(p.imagePath!),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 12),
                            const Text(
                              'আপনার সমস্যা:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(p.description),
                            if (p.isAnswered) ...[
                              const Divider(height: 24),
                              const Text(
                                'বিশেষজ্ঞের পরামর্শ:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(p.expertResponse ?? ''),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}

// ============================================================
// CALL TAB
// ============================================================

class _CallTab extends StatelessWidget {
  const _CallTab();

  static const String _helplineNumber = '+8801705500372';

  Future<void> _makeCall(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _helplineNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('কল করতে অক্ষম')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _makeCall(context),
            customBorder: const CircleBorder(),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.call, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'বিশেষজ্ঞকে কল করতে ট্যাপ করুন',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _helplineNumber,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA MODELS & SERVICES
// ============================================================

String timeLabel(DateTime dt) {
  final now = DateTime.now();
  Duration diff = now.difference(dt);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'এইমাত্র';
  if (diff.inHours < 1) return '${diff.inMinutes} মিনিট আগে';
  if (diff.inDays < 1) return '${diff.inHours} ঘন্টা আগে';
  return '${diff.inDays} দিন আগে';
}

class Problem {
  final String id;
  final String cropName;
  final String description;
  final String category;
  final bool urgent;
  final String? imagePath;
  final DateTime createdAt;
  String? expertResponse;
  DateTime? respondedAt;
  bool isAnswered;

  Problem({
    required this.id,
    required this.cropName,
    required this.description,
    required this.category,
    this.urgent = false,
    this.imagePath,
    required this.createdAt,
    this.expertResponse,
    this.respondedAt,
    this.isAnswered = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'description': description,
        'category': category,
        'urgent': urgent,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'expertResponse': expertResponse,
        'respondedAt': respondedAt?.toIso8601String(),
        'isAnswered': isAnswered,
      };

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
        id: json['id'] as String,
        cropName: json['cropName'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        urgent: json['urgent'] as bool? ?? false,
        imagePath: json['imagePath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expertResponse: json['expertResponse'] as String?,
        respondedAt: json['respondedAt'] != null
            ? DateTime.parse(json['respondedAt'] as String)
            : null,
        isAnswered: json['isAnswered'] as bool? ?? false,
      );
}

class ProblemRepository extends ChangeNotifier {
  static final ProblemRepository instance = ProblemRepository._();
  ProblemRepository._();

  final List<Problem> _problems = [];
  bool _initialized = false;

  List<Problem> get pending => _problems.where((p) => !p.isAnswered).toList();
  List<Problem> get answered => _problems.where((p) => p.isAnswered).toList();

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('problems');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _problems.addAll(list.map((e) => Problem.fromJson(e)));
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'problems',
      jsonEncode(_problems.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> submit(Problem problem) async {
    _problems.add(problem);
    await _save();
    notifyListeners();
  }

  Future<void> markAnswered({
    required String id,
    required String response,
  }) async {
    final problem = _problems.firstWhere((p) => p.id == id);
    problem.expertResponse = response;
    problem.respondedAt = DateTime.now();
    problem.isAnswered = true;
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _problems.removeWhere((p) => p.id == id);
    await _save();
    notifyListeners();
  }
}

class Expert {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String specialization;

  Expert({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.specialization,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'password': password,
        'specialization': specialization,
      };

  factory Expert.fromJson(Map<String, dynamic> json) => Expert(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        password: json['password'],
        specialization: json['specialization'],
      );
}

class ExpertAuthService extends ChangeNotifier {
  static final ExpertAuthService instance = ExpertAuthService._();
  ExpertAuthService._();

  Expert? _currentExpert;
  final List<Expert> _experts = [];
  bool _initialized = false;

  Expert? get currentExpert => _currentExpert;
  bool get isLoggedIn => _currentExpert != null;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final expertsJson = prefs.getString('experts');
    if (expertsJson != null) {
      final list = jsonDecode(expertsJson) as List;
      _experts.addAll(list.map((e) => Expert.fromJson(e)));
    }

    final currentExpertJson = prefs.getString('currentExpert');
    if (currentExpertJson != null) {
      _currentExpert = Expert.fromJson(jsonDecode(currentExpertJson));
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'experts',
      jsonEncode(_experts.map((e) => e.toJson()).toList()),
    );
    if (_currentExpert != null) {
      await prefs.setString(
        'currentExpert',
        jsonEncode(_currentExpert!.toJson()),
      );
    }
  }

  Future<String?> signUp({
    required String name,
    required String phone,
    required String password,
    required String specialization,
  }) async {
    await ensureInitialized();

    if (_experts.any((e) => e.phone == phone)) {
      return 'এই ফোন নম্বর দিয়ে ইতিমধ্যে একটি অ্যাকাউন্ট রয়েছে';
    }

    final expert = Expert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      password: password,
      specialization: specialization,
    );

    _experts.add(expert);
    _currentExpert = expert;
    await _save();
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    await ensureInitialized();

    try {
      final expert = _experts.firstWhere((e) => e.phone == phone);
      if (expert.password != password) {
        return 'ভুল পাসওয়ার্ড';
      }
      _currentExpert = expert;
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return 'এই ফোন নম্বর দিয়ে কোনো অ্যাকাউন্ট পাওয়া যায়নি';
    }
  }

  Future<void> logout() async {
    _currentExpert = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentExpert');
    notifyListeners();
  }

  Future<String?> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    await ensureInitialized();

    try {
      final expert = _experts.firstWhere((e) => e.phone == phone);
      final index = _experts.indexOf(expert);
      _experts[index] = Expert(
        id: expert.id,
        name: expert.name,
        phone: expert.phone,
        password: newPassword,
        specialization: expert.specialization,
      );
      await _save();
      return null;
    } catch (e) {
      return 'এই ফোন নম্বর দিয়ে কোনো অ্যাকাউন্ট পাওয়া যায়নি';
    }
  }
}
