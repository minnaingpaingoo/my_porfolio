import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/services/cloudinary_service.dart';
import 'package:my_porfolio/services/picked_image_file.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/custom_textfield.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';

/// Reusable Setup Form field that lets the Admin either:
/// 1) Import a local image file and upload it directly to Cloudinary (auto-filling
///    the returned `https://res.cloudinary.com/...` URL), or
/// 2) Enter/edit an image URL or bundled asset path manually.
class CloudinaryImagePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final double previewSize;
  final bool circularPreview;

  const CloudinaryImagePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.previewSize = 64,
    this.circularPreview = false,
  });

  @override
  State<CloudinaryImagePickerField> createState() =>
      _CloudinaryImagePickerFieldState();
}

class _CloudinaryImagePickerFieldState
    extends State<CloudinaryImagePickerField> {
  bool _isUploading = false;
  String? _uploadStatus;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    // Prefetch Cloudinary config from Firestore so it is ready before tap
    PortfolioRepository.instance.fetchCloudinaryConfigFromFirestore();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  Future<bool> _ensureCloudinaryConfigured() async {
    final repo = PortfolioRepository.instance;
    if (repo.cloudinaryConfig.isConfigured) {
      return true;
    }
    await repo.fetchCloudinaryConfigFromFirestore();
    if (repo.cloudinaryConfig.isConfigured) {
      return true;
    }
    if (!mounted) return false;
    return await showCloudinaryConfigDialog(context);
  }

  Future<void> _handleImportAndUpload() async {
    // Call pickImage() synchronously on user tap so the browser never blocks
    // the file dialog inside modal overlays.
    final picked = await CloudinaryService.pickImage();
    if (picked == null || !mounted) return;

    final configured = await _ensureCloudinaryConfigured();
    if (!configured || !mounted) return;

    setState(() {
      _isUploading = true;
      _isError = false;
      _uploadStatus = 'Uploading "${picked.name}" to Cloudinary...';
    });

    final result = await CloudinaryService.uploadImage(
      file: picked,
      config: PortfolioRepository.instance.cloudinaryConfig,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      widget.controller.text = result.secureUrl!;
      setState(() {
        _isUploading = false;
        _isError = false;
        _uploadStatus = 'Uploaded to Cloudinary successfully!';
      });
    } else {
      setState(() {
        _isUploading = false;
        _isError = true;
        _uploadStatus = result.errorMessage ?? 'Cloudinary upload failed.';
      });
    }
  }

  Widget _buildPreviewBox(String currentPath, {double? size}) {
    final dim = size ?? widget.previewSize;
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: CustomColor.scaffoldBg,
        shape: widget.circularPreview ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            widget.circularPreview ? null : BorderRadius.circular(12),
        border: Border.all(
          color: CustomColor.yellowPrimary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: widget.circularPreview
          ? ClipOval(
              child: PortfolioImage(
                imagePath: currentPath,
                width: dim,
                height: dim,
                fit: BoxFit.cover,
              ),
            )
          : PortfolioImage(
              imagePath: currentPath,
              width: dim,
              height: dim,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10),
            ),
    );
  }

  Widget _buildImportButton({bool compact = false}) {
    return ElevatedButton.icon(
      onPressed: _isUploading ? null : _handleImportAndUpload,
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.yellowPrimary,
        foregroundColor: CustomColor.scaffoldBg,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: _isUploading
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload_rounded, size: 17),
      label: Text(
        _isUploading
            ? "Uploading..."
            : compact
                ? "Import Image"
                : "Import Image File (Cloudinary)",
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSetupButton({bool compact = false}) {
    return OutlinedButton.icon(
      onPressed: () => showCloudinaryConfigDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: CustomColor.yellowSecondary,
        side: const BorderSide(color: CustomColor.cardBorder),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.settings_outlined, size: 15),
      label: Text(
        compact ? "Preset" : "Cloudinary Setup",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = widget.controller.text.trim();
    final isCompact = MediaQuery.of(context).size.width < 520;
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 14),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight2.withValues(alpha: 0.65),
        borderRadius: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            // Compact / Mobile Layout: stacked cleanly
            Row(
              children: [
                _buildPreviewBox(currentPath, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.labelText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: CustomColor.whitePrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        currentPath.isEmpty
                            ? "No image selected"
                            : currentPath,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CustomColor.hintDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextfield(
              controller: widget.controller,
              labelText: "Image URL or Asset Path",
              hintText: widget.hintText ??
                  "https://res.cloudinary.com/... or assets/...",
              prefixIcon: Icons.image_outlined,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildImportButton(compact: true)),
                const SizedBox(width: 8),
                _buildSetupButton(compact: true),
              ],
            ),
          ] else ...[
            // Wide / Desktop Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPreviewBox(currentPath),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextfield(
                        controller: widget.controller,
                        labelText: widget.labelText,
                        hintText: widget.hintText ??
                            "Import image to Cloudinary or paste URL / asset path",
                        prefixIcon: Icons.image_outlined,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildImportButton(),
                          _buildSetupButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (_uploadStatus != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 15,
                  color: _isError
                      ? CustomColor.crimsonAccent
                      : CustomColor.emeraldAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _uploadStatus!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isError
                          ? CustomColor.crimsonAccent
                          : CustomColor.emeraldAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog allowing the Admin to configure their Cloudinary Cloud Name and
/// either an Unsigned Upload Preset OR API Key + API Secret (persisted to
/// Cloud Firestore `portfolio_config/cloudinary`).
Future<bool> showCloudinaryConfigDialog(BuildContext context) async {
  final repo = PortfolioRepository.instance;
  await repo.fetchCloudinaryConfigFromFirestore();
  if (!context.mounted) return false;

  final current = repo.cloudinaryConfig;
  final cloudNameCtrl = TextEditingController(
    text: current.cloudName.startsWith('c-') && current.cloudName.length > 25
        ? ''
        : current.cloudName,
  );
  final presetCtrl = TextEditingController(
    text: current.uploadPreset.isNotEmpty ? current.uploadPreset : 'portfolio',
  );
  final apiKeyCtrl = TextEditingController(text: current.apiKey);
  final apiSecretCtrl = TextEditingController(
    text: current.apiSecret.isNotEmpty
        ? current.apiSecret
        : 'RlFFjt9wuCtvZm393g15esXRyT0',
  );
  final folderCtrl = TextEditingController(
    text: current.folder.isNotEmpty ? current.folder : 'my_portfolio',
  );
  String? errorMsg =
      (current.cloudName.startsWith('c-') && current.cloudName.length > 25)
          ? 'Note: "${current.cloudName}" is the Console URL ID, not your Cloud Name! Look at the top-left of Cloudinary Console (under the cloud icon) or Settings → API Keys for your short Cloud Name (e.g. dxxxxxxxx).'
          : null;

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: CustomColor.bgLight1,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: CustomColor.cardBorder),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  color: CustomColor.yellowPrimary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Cloudinary Storage Setup",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: (MediaQuery.of(dialogContext).size.width - 72)
                  .clamp(240.0, 460.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Why did '401 Unknown API Key' happen?\n"
                      "• If your Upload Preset in Cloudinary is set to 'Signed' (default), Cloudinary requires your API Key & API Secret below.\n"
                      "• Or, if you change your Upload Preset's Signing Mode to 'Unsigned' in Cloudinary Console, you only need Cloud Name + Upload Preset.",
                      style: TextStyle(
                        fontSize: 12.5,
                        color: CustomColor.whiteSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      controller: cloudNameCtrl,
                      labelText: "Cloudinary Cloud Name (Required)",
                      prefixIcon: Icons.cloud_outlined,
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: presetCtrl,
                      labelText: "Upload Preset Name (Required if Unsigned)",
                      prefixIcon: Icons.tune_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: apiKeyCtrl,
                      labelText: "API Key (Required if Preset is Signed)",
                      prefixIcon: Icons.vpn_key_outlined,
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: apiSecretCtrl,
                      labelText: "API Secret (Required if Preset is Signed)",
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: folderCtrl,
                      labelText: "Target Folder (optional)",
                      prefixIcon: Icons.folder_open_rounded,
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMsg!,
                        style: const TextStyle(
                          color: CustomColor.crimsonAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  String cloud = cloudNameCtrl.text.trim();
                  String key = apiKeyCtrl.text.trim();
                  String secret = apiSecretCtrl.text.trim();

                  // Support pasting full CLOUDINARY_URL=cloudinary://key:secret@cloud_name
                  if (cloud.contains('cloudinary://')) {
                    final cleaned =
                        cloud.replaceAll('CLOUDINARY_URL=', '').trim();
                    final uri = Uri.tryParse(cleaned);
                    if (uri != null && uri.host.isNotEmpty) {
                      cloud = uri.host;
                      final userInfoParts = uri.userInfo.split(':');
                      if (userInfoParts.isNotEmpty &&
                          userInfoParts[0].isNotEmpty) {
                        key = userInfoParts[0];
                      }
                      if (userInfoParts.length > 1 &&
                          userInfoParts[1].isNotEmpty) {
                        secret = userInfoParts[1];
                      }
                    }
                  }

                  if (cloud.startsWith('c-') && cloud.length > 25) {
                    setDialogState(() {
                      errorMsg =
                          '"$cloud" is the Console URL Account ID, not your Cloud Name. Copy your real Cloud Name from the top-left of Cloudinary Dashboard or Settings → API Keys.';
                    });
                    return;
                  }

                  final hasCloud = cloud.isNotEmpty;
                  final hasPreset = presetCtrl.text.trim().isNotEmpty;
                  final hasApiCreds = key.isNotEmpty && secret.isNotEmpty;

                  if (!hasCloud || (!hasPreset && !hasApiCreds)) {
                    setDialogState(() {
                      errorMsg =
                          "Enter your real Cloud Name plus either an Unsigned Upload Preset OR your API Key & API Secret.";
                    });
                    return;
                  }
                  await repo.saveCloudinaryConfig(
                    CloudinaryConfig(
                      cloudName: cloud,
                      uploadPreset: presetCtrl.text.trim(),
                      apiKey: key,
                      apiSecret: secret,
                      folder: folderCtrl.text.trim(),
                    ),
                  );
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.yellowPrimary,
                  foregroundColor: CustomColor.scaffoldBg,
                ),
                icon: const Icon(Icons.save_rounded, size: 17),
                label: const Text(
                  "Save Setup",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  return saved == true;
}
