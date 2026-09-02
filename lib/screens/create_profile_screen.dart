import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/dog_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dog_provider.dart';
import '../theme/paw_colors.dart';
import '../widgets/network_photo.dart';

const List<String> _dogAvatarOptions = [
  'https://placedog.net/300/300?id=1',
  'https://placedog.net/300/300?id=2',
  'https://placedog.net/300/300?id=3',
  'https://placedog.net/300/300?id=4',
  'https://placedog.net/300/300?id=5',
  'https://placedog.net/300/300?id=6',
  'https://placedog.net/300/300?id=7',
  'https://placedog.net/300/300?id=8',
];

const List<int> _ownerAvatarOptions = [5, 8, 11, 14, 18, 21, 24, 29];

const List<String> _personalityOptions = [
  'Energetic', 'Calm', 'Affectionate', 'Loyal', 'Smart', 'Playful',
  'Lazy', 'Protective', 'Curious', 'Foodie', 'Vocal', 'Cuddly',
  'Stubborn', 'Gentle', 'Well-trained', 'Herder',
];

const List<String> _interestOptions = [
  'Hiking', 'Running', 'Coffee', 'Reading', 'Cooking', 'Travel',
  'Photography', 'Board games', 'Music', 'Movies', 'Yoga', 'Camping',
  'Beach days', 'Craft beer', 'Gardening', 'Brunch',
];

/// Lo primero que ve cualquiera que se acabe de registrar — antes de
/// entrar a la app hay que montar el perfil (perro + dueño). Las cuentas
/// que inician sesión (no se registran) se saltan esto, ver AuthGate.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _pageController = PageController();
  int _step = 0;
  static const _totalSteps = 5;

  final dogNameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerBioController = TextEditingController();
  final dogDescriptionController = TextEditingController();

  int dogAvatarIndex = 0;
  int ownerAvatarIndex = 0;
  final Set<MatchPurpose> selectedPurposes = {};
  OwnerIntent selectedIntent = OwnerIntent.dogsOnly;
  final Set<String> selectedTraits = {};
  final Set<String> selectedInterests = {};

  @override
  void dispose() {
    _pageController.dispose();
    dogNameController.dispose();
    breedController.dispose();
    ageController.dispose();
    ownerNameController.dispose();
    ownerBioController.dispose();
    dogDescriptionController.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return dogNameController.text.trim().isNotEmpty && breedController.text.trim().isNotEmpty && (int.tryParse(ageController.text.trim()) ?? 0) > 0;
      case 2:
        return selectedPurposes.isNotEmpty;
      case 4:
        return ownerNameController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _goNext() {
    if (!_canAdvance) return;
    if (_step == _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _step++);
    _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _goBack() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _finish() {
    final years = int.tryParse(ageController.text.trim()) ?? 1;
    final dog = Dog(
      id: 'me-1',
      name: dogNameController.text.trim(),
      breed: breedController.text.trim(),
      ageInMonths: years * 12,
      photoUrl: _dogAvatarOptions[dogAvatarIndex],
      description: dogDescriptionController.text.trim(),
      purposes: selectedPurposes.toList(),
      personalityTags: selectedTraits.toList(),
      ownerName: ownerNameController.text.trim(),
      ownerPhotoUrl: 'https://i.pravatar.cc/300?img=${_ownerAvatarOptions[ownerAvatarIndex]}',
      ownerBio: ownerBioController.text.trim(),
      ownerInterests: selectedInterests.toList(),
      ownerIntent: selectedIntent,
    );
    context.read<DogProvider>().setMyDog(dog);
    context.read<AuthProvider>().markProfileComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: PawColors.pine),
                      tooltip: 'Back',
                      onPressed: _goBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _totalSteps,
                        minHeight: 6,
                        backgroundColor: PawColors.surfaceMuted,
                        color: PawColors.mustard,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DogBasicsStep(nameController: dogNameController, breedController: breedController, ageController: ageController, onChanged: () => setState(() {})),
                  _AvatarPickerStep(
                    title: "Pick a photo for ${dogNameController.text.trim().isEmpty ? 'your dog' : dogNameController.text.trim()}",
                    options: _dogAvatarOptions,
                    selectedIndex: dogAvatarIndex,
                    onSelected: (i) => setState(() => dogAvatarIndex = i),
                  ),
                  _LookingForStep(
                    selectedPurposes: selectedPurposes,
                    selectedIntent: selectedIntent,
                    onPurposesChanged: (p) => setState(() {
                      if (selectedPurposes.contains(p)) {
                        selectedPurposes.remove(p);
                      } else {
                        selectedPurposes.add(p);
                      }
                    }),
                    onIntentChanged: (i) => setState(() => selectedIntent = i),
                  ),
                  _TagPickerStep(
                    title: "What's ${dogNameController.text.trim().isEmpty ? 'your dog' : dogNameController.text.trim()} like?",
                    subtitle: 'Pick a few personality traits (optional).',
                    options: _personalityOptions,
                    selected: selectedTraits,
                    maxSelection: 5,
                    onToggle: (tag) => setState(() {
                      if (selectedTraits.contains(tag)) {
                        selectedTraits.remove(tag);
                      } else if (selectedTraits.length < 5) {
                        selectedTraits.add(tag);
                      }
                    }),
                  ),
                  _AboutYouStep(
                    ownerNameController: ownerNameController,
                    ownerBioController: ownerBioController,
                    dogDescriptionController: dogDescriptionController,
                    dogName: dogNameController.text.trim(),
                    ownerAvatarIndex: ownerAvatarIndex,
                    onOwnerAvatarSelected: (i) => setState(() => ownerAvatarIndex = i),
                    interestOptions: _interestOptions,
                    selectedInterests: selectedInterests,
                    onInterestToggle: (tag) => setState(() {
                      if (selectedInterests.contains(tag)) {
                        selectedInterests.remove(tag);
                      } else {
                        selectedInterests.add(tag);
                      }
                    }),
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _canAdvance ? [BoxShadow(color: PawColors.mustard.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))] : null,
                ),
                child: ElevatedButton(
                  onPressed: _canAdvance ? _goNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawColors.mustard,
                    foregroundColor: PawColors.pine,
                    disabledBackgroundColor: PawColors.surfaceMuted,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    _step == _totalSteps - 1 ? 'Finish' : 'Continue',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _StepHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w600, color: PawColors.pine)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: GoogleFonts.manrope(fontSize: 13.5, color: PawColors.charcoal.withValues(alpha: 0.6))),
        ],
      ],
    );
  }
}

class _DogBasicsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController breedController;
  final TextEditingController ageController;
  final VoidCallback onChanged;

  const _DogBasicsStep({required this.nameController, required this.breedController, required this.ageController, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(title: "Let's meet your dog", subtitle: "First things first — tell us the basics."),
          const SizedBox(height: 24),
          _FieldLabel(text: "DOG'S NAME"),
          const SizedBox(height: 6),
          _TextInput(key: const Key('dogNameField'), controller: nameController, hint: 'e.g. Rocky', onChanged: onChanged),
          const SizedBox(height: 16),
          _FieldLabel(text: 'BREED'),
          const SizedBox(height: 6),
          _TextInput(key: const Key('breedField'), controller: breedController, hint: 'e.g. Golden Retriever', onChanged: onChanged),
          const SizedBox(height: 16),
          _FieldLabel(text: 'AGE (YEARS)'),
          const SizedBox(height: 6),
          _TextInput(key: const Key('ageField'), controller: ageController, hint: 'e.g. 2', keyboardType: TextInputType.number, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AvatarPickerStep extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AvatarPickerStep({required this.title, required this.options, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: title, subtitle: 'Pick whichever one feels right — you can always change it later.'),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, i) {
              final selected = i == selectedIndex;
              return GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? PawColors.mustard : Colors.transparent, width: 3),
                    boxShadow: [BoxShadow(color: PawColors.charcoal.withValues(alpha: selected ? 0.2 : 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(child: NetworkPhoto(url: options[i])),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LookingForStep extends StatelessWidget {
  final Set<MatchPurpose> selectedPurposes;
  final OwnerIntent selectedIntent;
  final ValueChanged<MatchPurpose> onPurposesChanged;
  final ValueChanged<OwnerIntent> onIntentChanged;

  const _LookingForStep({required this.selectedPurposes, required this.selectedIntent, required this.onPurposesChanged, required this.onIntentChanged});

  @override
  Widget build(BuildContext context) {
    final bodyFont = GoogleFonts.manrope;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(title: 'What are you looking for?', subtitle: 'Pick at least one — you can select more than one.'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MatchPurpose.values.map((purpose) {
              final selected = selectedPurposes.contains(purpose);
              return ChoiceChip(
                label: Text(purpose.label),
                selected: selected,
                onSelected: (_) => onPurposesChanged(purpose),
                selectedColor: PawColors.pine,
                labelStyle: bodyFont(fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
                backgroundColor: Colors.white,
                side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text('AND AS THE OWNER —', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(
            "PawMatch is for dogs and their people. This is about you, not just ${selectedPurposes.isEmpty ? 'your dog' : 'them'}.",
            style: bodyFont(fontSize: 13, color: PawColors.charcoal.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: OwnerIntent.values.map((intent) {
              final selected = selectedIntent == intent;
              return ChoiceChip(
                label: Text('${intent.emoji} ${intent.label}'),
                selected: selected,
                onSelected: (_) => onIntentChanged(intent),
                selectedColor: PawColors.pine,
                labelStyle: bodyFont(fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
                backgroundColor: Colors.white,
                side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TagPickerStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final int maxSelection;
  final ValueChanged<String> onToggle;

  const _TagPickerStep({required this.title, required this.subtitle, required this.options, required this.selected, required this.maxSelection, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bodyFont = GoogleFonts.manrope;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: title, subtitle: '$subtitle Up to $maxSelection.'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((tag) {
              final isSelected = selected.contains(tag);
              final isDisabled = !isSelected && selected.length >= maxSelection;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: isDisabled ? null : (_) => onToggle(tag),
                selectedColor: PawColors.pine,
                labelStyle: bodyFont(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : (isDisabled ? PawColors.charcoal.withValues(alpha: 0.3) : PawColors.pine)),
                backgroundColor: Colors.white,
                side: BorderSide(color: PawColors.sage.withValues(alpha: isDisabled ? 0.2 : 0.5)),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AboutYouStep extends StatelessWidget {
  final TextEditingController ownerNameController;
  final TextEditingController ownerBioController;
  final TextEditingController dogDescriptionController;
  final String dogName;
  final int ownerAvatarIndex;
  final ValueChanged<int> onOwnerAvatarSelected;
  final List<String> interestOptions;
  final Set<String> selectedInterests;
  final ValueChanged<String> onInterestToggle;
  final VoidCallback onChanged;

  const _AboutYouStep({
    required this.ownerNameController,
    required this.ownerBioController,
    required this.dogDescriptionController,
    required this.dogName,
    required this.ownerAvatarIndex,
    required this.onOwnerAvatarSelected,
    required this.interestOptions,
    required this.selectedInterests,
    required this.onInterestToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bodyFont = GoogleFonts.manrope;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(title: 'Last thing — about you', subtitle: "This is what other owners see, not just your dog's profile."),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(_ownerAvatarOptions.length, (i) {
                final selected = i == ownerAvatarIndex;
                return GestureDetector(
                  onTap: () => onOwnerAvatarSelected(i),
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? PawColors.mustard : Colors.transparent, width: 3),
                    ),
                    child: ClipOval(child: NetworkPhoto(url: 'https://i.pravatar.cc/150?img=${_ownerAvatarOptions[i]}')),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          _FieldLabel(text: 'YOUR NAME'),
          const SizedBox(height: 6),
          _TextInput(key: const Key('ownerNameField'), controller: ownerNameController, hint: 'e.g. Lucas', onChanged: onChanged),
          const SizedBox(height: 16),
          _FieldLabel(text: 'YOUR BIO (OPTIONAL)'),
          const SizedBox(height: 6),
          _TextInput(controller: ownerBioController, hint: 'A line about you...', maxLines: 2),
          const SizedBox(height: 16),
          _FieldLabel(text: dogName.isEmpty ? "ABOUT YOUR DOG (OPTIONAL)" : "ABOUT $dogName (OPTIONAL)"),
          const SizedBox(height: 6),
          _TextInput(controller: dogDescriptionController, hint: 'Personality, quirks, favorite park...', maxLines: 3),
          const SizedBox(height: 20),
          Text('YOUR INTERESTS (OPTIONAL)', style: bodyFont(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text('Helps break the ice if it turns into more than a walk.', style: bodyFont(fontSize: 12, color: PawColors.charcoal.withValues(alpha: 0.5))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interestOptions.map((tag) {
              final selected = selectedInterests.contains(tag);
              return ChoiceChip(
                label: Text(tag),
                selected: selected,
                onSelected: (_) => onInterestToggle(tag),
                selectedColor: PawColors.pine,
                labelStyle: bodyFont(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : PawColors.pine),
                backgroundColor: Colors.white,
                side: BorderSide(color: PawColors.sage.withValues(alpha: 0.5)),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: PawColors.charcoal.withValues(alpha: 0.5)).copyWith(letterSpacing: 1.2),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final VoidCallback? onChanged;

  const _TextInput({super.key, required this.controller, required this.hint, this.keyboardType, this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PawColors.sage.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: PawColors.charcoal.withValues(alpha: 0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: maxLines > 1 ? 12 : 0),
        ),
      ),
    );
  }
}
