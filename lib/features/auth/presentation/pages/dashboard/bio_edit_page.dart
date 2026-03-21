import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';
import 'package:partnex/core/theme/widgets/custom_button.dart';
import 'package:partnex/core/services/ui_service.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';

class BioEditPage extends StatefulWidget {
  final String initialBio;
  final String initialWebsite;
  final String initialWhatsapp;
  final String initialLinkedin;
  final String initialTwitter;

  const BioEditPage({
    super.key,
    this.initialBio = '',
    this.initialWebsite = '',
    this.initialWhatsapp = '',
    this.initialLinkedin = '',
    this.initialTwitter = '',
  });

  @override
  State<BioEditPage> createState() => _BioEditPageState();
}

class _BioEditPageState extends State<BioEditPage> {
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _twitterController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
    _websiteController = TextEditingController(text: widget.initialWebsite);
    _whatsappController = TextEditingController(text: widget.initialWhatsapp);
    _linkedinController = TextEditingController(text: widget.initialLinkedin);
    _twitterController = TextEditingController(text: widget.initialTwitter);
    _bioController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _whatsappController.addListener(_onFieldChanged);
    _linkedinController.addListener(_onFieldChanged);
    _twitterController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _isDirty {
    return _bioController.text.trim() != widget.initialBio.trim() ||
           _websiteController.text.trim() != widget.initialWebsite.trim() ||
           _whatsappController.text.trim() != widget.initialWhatsapp.trim() ||
           _linkedinController.text.trim() != widget.initialLinkedin.trim() ||
           _twitterController.text.trim() != widget.initialTwitter.trim();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _websiteController.dispose();
    _whatsappController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() => _isSaving = true);

    context.read<SmeProfileCubit>().updateBio(
      bio: _bioController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      linkedinUrl: _linkedinController.text.trim(),
      twitterHandle: _twitterController.text.trim(),
    );

    // Save to backend but skip score generation
    final state = context.read<SmeProfileCubit>().state;
    context.read<AuthBloc>().add(SubmitSmeProfileEvent(state.toMap(), shouldGenerateScore: false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!ModalRoute.of(context)!.isCurrent) return;
        if (state is SmeProfileSubmittedSuccess) {
          setState(() => _isSaving = false);
          uiService.showSnackBar('Profile updated successfully');
          uiService.goBack();
        } else if (state is SmeProfileSubmissionError) {
          setState(() => _isSaving = false);
          uiService.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutralWhite,
        appBar: AppBar(
          backgroundColor: AppColors.neutralWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
            onPressed: () => uiService.goBack(),
          ),
          title: Text(
            'Edit Bio',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.slate900,
            ),
          ),
          titleSpacing: 0,
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.slate200, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bio Section
              Text(
                'About Your Business',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                maxLength: 7000,
                maxLines: 8,
                minLines: 6,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                decoration: InputDecoration(
                hintText: 'Tell investors about your business, mission, team, and achievements...',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.slate400,
                ),
                filled: true,
                fillColor: AppColors.neutralWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColors.slate300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: AppColors.slate300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.linkBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.slate900,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '${_bioController.text.trim().isEmpty ? 0 : _bioController.text.trim().split(RegExp(r'\s+')).length} / 1000 words',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.slate600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Social Links Section
            Text(
              'Connect With You',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 12),

            _buildSocialField(
              icon: LucideIcons.globe,
              label: 'Website',
              controller: _websiteController,
              placeholder: 'https://yourwebsite.com',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildSocialField(
              icon: LucideIcons.messageCircle,
              label: 'WhatsApp',
              controller: _whatsappController,
              placeholder: '+1 (555) 123-4567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildSocialField(
              icon: LucideIcons.linkedin,
              label: 'LinkedIn',
              controller: _linkedinController,
              placeholder: 'linkedin.com/in/yourprofile',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildSocialField(
              icon: LucideIcons.twitter,
              label: 'Twitter',
              controller: _twitterController,
              placeholder: '@yourhandle',
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 24),

            // Save Button
            CustomButton(
              text: _isSaving ? 'Saving...' : 'Save Bio',
              variant: ButtonVariant.primary,
              isDisabled: _isSaving || !_isDirty,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSocialField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.slate600),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppColors.slate400,
            ),
            filled: true,
            fillColor: AppColors.neutralWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.slate300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.slate300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.linkBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: AppColors.slate900,
          ),
        ),
      ],
    );
  }
}
