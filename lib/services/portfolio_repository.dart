import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_porfolio/db/portfolio_db.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/local_storage_stub.dart'
    if (dart.library.html) 'package:my_porfolio/services/local_storage_web.dart';
import 'package:my_porfolio/services/picked_image_file.dart';
import 'package:my_porfolio/utils/project_utils.dart';

/// Central reactive data store for the Storybook Portfolio & Admin CMS.
/// Models have zero hardcoded default strings. Backup/seed records are stored
/// in `assets/portfolio_db.json` and automatically loaded & synced to
/// Cloud Firestore (`my-portfolio-b1b1c`) when Firestore is empty or on demand.
class PortfolioRepository extends ChangeNotifier {
  static final PortfolioRepository instance = PortfolioRepository._internal();

  PortfolioRepository._internal();

  static const String appVersion = '2.0.0';
  static const String dbFilePath = 'lib/db/portfolio_db.json';
  static const String _deviceTemplateStorageKey = 'portfolio_device_template';

  /// Dynamic daily passcode formula: (day + 7)(month + 7)(year + 7)
  /// Example: 23/11/2026 -> (23+7)(11+7)(2026+7) -> 30182033
  static String generateDailyPasscode([DateTime? date]) {
    final d = (date ?? DateTime.now()).toLocal();
    final dayPart = d.day + 7;
    final monthPart = d.month + 7;
    final yearPart = d.year + 7;
    return '$dayPart$monthPart$yearPart';
  }

  bool _isFirebaseAvailable = false;
  bool _isSyncing = false;
  bool _isLocalAdminUnlocked = false;
  User? _firebaseUser;
  String? _statusMessage;
  String? _lastFirestoreError;
  String? _visitorTemplateOverride;

  ProfileData? _profile = const ProfileData();
  CloudinaryConfig? _cloudinaryConfig = const CloudinaryConfig();
  List<ExperienceItem>? _experiences = [];
  List<EducationItem>? _educations = [];
  List<PlatformItem>? _platforms = [];
  List<SkillItem>? _skills = [];
  List<ProjectUtils>? _projects = [];
  List<ContactMessage>? _messages = [];

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // Getters (null-safe across Flutter Web hot reloads)
  bool get isFirebaseAvailable => _isFirebaseAvailable;
  bool get isSyncing => _isSyncing;
  bool get isAdminAuthenticated =>
      _isLocalAdminUnlocked || _firebaseUser != null;
  User? get firebaseUser => _firebaseUser;
  String? get statusMessage => _statusMessage;
  String? get lastFirestoreError => _lastFirestoreError;

  ProfileData get profile => _profile ??= const ProfileData();

  /// Default UI/UX template configured by the Admin in Cloud Firestore:
  /// 'book_reader', 'storybook', 'bento', or 'minimal'.
  String get defaultTemplate {
    final fromProfile = profile.selectedTemplate.trim();
    return fromProfile.isNotEmpty ? fromProfile : 'book_reader';
  }

  /// Device-local template chosen by the user from the public user panel.
  /// Stored only on the user's device (localStorage) and never sent to Firebase.
  String? get visitorTemplateOverride {
    final cached = _visitorTemplateOverride;
    if (cached != null && cached.trim().isNotEmpty) {
      return cached.trim();
    }
    final stored = readDeviceLocalValue(_deviceTemplateStorageKey);
    if (stored != null && stored.trim().isNotEmpty) {
      _visitorTemplateOverride = stored.trim();
      return _visitorTemplateOverride;
    }
    return null;
  }

  bool get hasVisitorTemplateOverride => visitorTemplateOverride != null;

  /// Active UI/UX template ID rendered on this device ('storybook', 'bento', or 'minimal').
  /// Uses the user's device-local template choice if set; otherwise falls back
  /// to the Admin's default `selectedTemplate` from Cloud Firestore.
  String get activeTemplate {
    final override = visitorTemplateOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return defaultTemplate;
  }

  /// Changes the template ONLY on the user's device (localStorage + memory).
  /// Does NOT update Firebase / Cloud Firestore.
  void setVisitorTemplate(String templateId) {
    final normalized = templateId.trim();
    if (normalized.isEmpty) return;
    _visitorTemplateOverride = normalized;
    writeDeviceLocalValue(_deviceTemplateStorageKey, normalized);
    notifyListeners();
  }

  /// Clears the device-local template override so this device follows the
  /// Admin's default template from Cloud Firestore.
  void clearVisitorTemplateOverride() {
    _visitorTemplateOverride = null;
    writeDeviceLocalValue(_deviceTemplateStorageKey, null);
    notifyListeners();
  }

  /// Called ONLY from the Admin Panel to set the global default template in
  /// Cloud Firestore (`portfolio_config/profile.selectedTemplate`).
  Future<String> setDefaultTemplateInFirestore(String templateId) async {
    _visitorTemplateOverride = null;
    writeDeviceLocalValue(_deviceTemplateStorageKey, null);
    if (profile.fullName.isEmpty && _isFirebaseAvailable) {
      await fetchProfileFromFirestore();
    }
    _profile = profile.copyWith(selectedTemplate: templateId);
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('portfolio_config')
            .doc('profile')
            .set(
          {'selectedTemplate': templateId},
          SetOptions(merge: true),
        );
        _lastFirestoreError = null;
        notifyListeners();
        return 'Saved default template to Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally (Firestore notice: $_lastFirestoreError)';
      }
    }
    return 'Default template updated locally.';
  }

  CloudinaryConfig get cloudinaryConfig =>
      _cloudinaryConfig ??= const CloudinaryConfig();
  List<ExperienceItem> get experiences =>
      List.unmodifiable(_experiences ??= <ExperienceItem>[]);
  List<EducationItem> get educations =>
      List.unmodifiable(_educations ??= <EducationItem>[]);
  List<PlatformItem> get platforms =>
      List.unmodifiable(_platforms ??= <PlatformItem>[]);
  List<SkillItem> get skills => List.unmodifiable(_skills ??= <SkillItem>[]);
  List<ProjectUtils> get allProjects =>
      List.unmodifiable(_projects ??= <ProjectUtils>[]);

  List<ProjectUtils> get workProjects => (_projects ??= <ProjectUtils>[])
      .where((p) => p.projectType.toLowerCase() != 'hobby')
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  List<ProjectUtils> get hobbyProjects => (_projects ??= <ProjectUtils>[])
      .where((p) => p.projectType.toLowerCase() == 'hobby')
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  List<ContactMessage> get messages =>
      List.unmodifiable(_messages ??= <ContactMessage>[]);
  int get unreadMessageCount =>
      (_messages ??= <ContactMessage>[]).where((m) => !m.isRead).length;

  void _recordFirestoreError(Object error) {
    if (error is FirebaseException) {
      _lastFirestoreError =
          '[${error.code}] ${error.message ?? error.toString()}';
    } else {
      _lastFirestoreError = error.toString();
    }
    debugPrint('Cloud Firestore error: $_lastFirestoreError');
    notifyListeners();
  }

  /// Loads the backup DB file (`lib/db/portfolio_db.json` with hot-reload fallback
  /// to `lib/db/portfolio_db.dart`) into memory, and optionally syncs all records
  /// to Cloud Firestore.
  Future<String> loadFromDbFile({bool syncToCloud = true}) async {
    try {
      Map<String, dynamic> db;
      try {
        final rawJson = await rootBundle.loadString(dbFilePath);
        db = jsonDecode(rawJson) as Map<String, dynamic>;
      } catch (_) {
        db = kPortfolioSeedDb;
      }

      if (db['profile'] is Map) {
        _profile =
            ProfileData.fromMap(Map<String, dynamic>.from(db['profile']));
      }

      if (db['experiences'] is List) {
        _experiences = (db['experiences'] as List)
            .whereType<Map>()
            .map((m) => ExperienceItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      if (db['educations'] is List) {
        _educations = (db['educations'] as List)
            .whereType<Map>()
            .map((m) => EducationItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      if (db['platforms'] is List) {
        _platforms = (db['platforms'] as List)
            .whereType<Map>()
            .map((m) => PlatformItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      if (db['skills'] is List) {
        _skills = (db['skills'] as List)
            .whereType<Map>()
            .map((m) => SkillItem.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      if (db['projects'] is List) {
        _projects = (db['projects'] as List)
            .whereType<Map>()
            .map((m) => ProjectUtils.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }

      notifyListeners();

      if (syncToCloud && _isFirebaseAvailable) {
        return await seedAllToFirestore();
      }
      return 'Loaded portfolio data from $dbFilePath.';
    } catch (e) {
      debugPrint('Failed to load $dbFilePath: $e');
      return 'Error loading $dbFilePath: $e';
    }
  }

  /// Connects to Firebase Auth & Cloud Firestore streams if Firebase was initialized.
  /// If Firestore is empty (no profile or projects exist), it automatically loads
  /// `assets/portfolio_db.json` and syncs it to Cloud Firestore.
  Future<void> initializeFirebaseSync() async {
    try {
      if (Firebase.apps.isEmpty) {
        _isFirebaseAvailable = false;
        await loadFromDbFile(syncToCloud: false);
        return;
      }

      for (final sub in _subscriptions) {
        await sub.cancel();
      }
      _subscriptions.clear();

      _isFirebaseAvailable = true;
      _lastFirestoreError = null;

      // Listen to Firebase Auth state
      final authSub = FirebaseAuth.instance.authStateChanges().listen(
        (User? user) {
          _firebaseUser = user;
          notifyListeners();
        },
        onError: (_) {},
      );
      _subscriptions.add(authSub);

      final firestore = FirebaseFirestore.instance;

      // Check if Firestore database is empty; if empty, load from assets/portfolio_db.json and sync!
      try {
        final profileDoc = await firestore
            .collection('portfolio_config')
            .doc('profile')
            .get();
        final projectsSnap =
            await firestore.collection('projects').limit(1).get();
        if (!profileDoc.exists || projectsSnap.docs.isEmpty) {
          await loadFromDbFile(syncToCloud: true);
        }
      } catch (e) {
        _recordFirestoreError(e);
        await loadFromDbFile(syncToCloud: false);
      }

      // 1. Profile document listener
      _subscriptions.add(
        firestore
            .collection('portfolio_config')
            .doc('profile')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          if (snapshot.exists && snapshot.data() != null) {
            _profile = ProfileData.fromMap(snapshot.data()!);
            notifyListeners();
          }
        }, onError: _recordFirestoreError),
      );

      // 2. Experiences collection listener
      _subscriptions.add(
        firestore
            .collection('experiences')
            .orderBy('order')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _experiences = snapshot.docs
              .map((d) => ExperienceItem.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 3. Educations collection listener
      _subscriptions.add(
        firestore
            .collection('educations')
            .orderBy('order')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _educations = snapshot.docs
              .map((d) => EducationItem.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 4. Platforms collection listener
      _subscriptions.add(
        firestore
            .collection('platforms')
            .orderBy('order')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _platforms = snapshot.docs
              .map((d) => PlatformItem.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 5. Skills collection listener
      _subscriptions.add(
        firestore
            .collection('skills')
            .orderBy('order')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _skills = snapshot.docs
              .map((d) => SkillItem.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 6. Projects collection listener
      _subscriptions.add(
        firestore
            .collection('projects')
            .orderBy('order')
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _projects = snapshot.docs
              .map((d) => ProjectUtils.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 7. Messages collection listener
      _subscriptions.add(
        firestore
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          _lastFirestoreError = null;
          _messages = snapshot.docs
              .map((d) => ContactMessage.fromMap(d.data(), docId: d.id))
              .toList();
          notifyListeners();
        }, onError: _recordFirestoreError),
      );

      // 8. Cloudinary config listener
      _subscriptions.add(
        firestore
            .collection('portfolio_config')
            .doc('cloudinary')
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            _cloudinaryConfig = CloudinaryConfig.fromMap(snapshot.data()!);
            notifyListeners();
          }
        }, onError: (_) {}),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync unavailable: $e');
      _isFirebaseAvailable = false;
      await loadFromDbFile(syncToCloud: false);
    }
  }

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  Future<String?> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseAvailable) {
      return 'Firebase Auth is not reachable in this environment.';
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLocalAdminUnlocked = true;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed (${e.code}).';
    } catch (e) {
      return e.toString();
    }
  }

  bool signInWithPasskey(String passkey, {DateTime? date}) {
    final trimmed = passkey.trim();
    if (trimmed.isEmpty) return false;
    final d = (date ?? DateTime.now()).toLocal();
    final expected = generateDailyPasscode(d);
    final expectedPadded =
        '${(d.day + 7).toString().padLeft(2, '0')}${(d.month + 7).toString().padLeft(2, '0')}${d.year + 7}';

    if (trimmed == expected || trimmed == expectedPadded) {
      _isLocalAdminUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signOutAdmin() async {
    _isLocalAdminUnlocked = false;
    if (_isFirebaseAvailable) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    notifyListeners();
  }

  // ===========================================================================
  // SYNC TO CLOUD FIRESTORE
  // ===========================================================================

  Future<String> seedAllToFirestore() async {
    _isSyncing = true;
    notifyListeners();

    if (!_isFirebaseAvailable) {
      _isSyncing = false;
      notifyListeners();
      return 'Firebase not initialized.';
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      batch.set(
        firestore.collection('portfolio_config').doc('profile'),
        profile.toMap(),
      );

      for (final exp in experiences) {
        batch.set(
          firestore.collection('experiences').doc(exp.id),
          exp.toMap(),
        );
      }

      for (final edu in educations) {
        batch.set(
          firestore.collection('educations').doc(edu.id),
          edu.toMap(),
        );
      }

      for (final plat in platforms) {
        batch.set(
          firestore.collection('platforms').doc(plat.id),
          plat.toMap(),
        );
      }

      for (final skill in skills) {
        batch.set(
          firestore.collection('skills').doc(skill.id),
          skill.toMap(),
        );
      }

      for (final proj in allProjects) {
        final docId = proj.id.isNotEmpty
            ? proj.id
            : 'proj_${DateTime.now().millisecondsSinceEpoch}';
        batch.set(
          firestore.collection('projects').doc(docId),
          proj.copyWith(id: docId).toMap(),
        );
      }

      await batch.commit();
      _isSyncing = false;
      _lastFirestoreError = null;
      _statusMessage = 'All chapters stored in Cloud Firestore!';
      notifyListeners();
      return 'Successfully synced all chapters from DB file to Cloud Firestore (my-portfolio-b1b1c)!';
    } catch (e) {
      _isSyncing = false;
      _recordFirestoreError(e);
      return 'Firestore write blocked: $_lastFirestoreError';
    }
  }

  // ===========================================================================
  // CRUD: PROFILE, PROLOGUE & CLOUDINARY CONFIG
  // ===========================================================================

  /// Explicitly fetches the latest `portfolio_config/profile` document from
  /// Cloud Firestore before editing in the Admin Panel.
  Future<ProfileData> fetchProfileFromFirestore() async {
    if (_isFirebaseAvailable) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('portfolio_config')
            .doc('profile')
            .get();
        if (doc.exists && doc.data() != null) {
          _profile = ProfileData.fromMap(doc.data()!);
          _lastFirestoreError = null;
          notifyListeners();
        }
      } catch (e) {
        _recordFirestoreError(e);
      }
    }
    return profile;
  }

  Future<CloudinaryConfig> fetchCloudinaryConfigFromFirestore() async {
    if (_isFirebaseAvailable) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('portfolio_config')
            .doc('cloudinary')
            .get();
        if (doc.exists && doc.data() != null) {
          _cloudinaryConfig = CloudinaryConfig.fromMap(doc.data()!);
          notifyListeners();
        }
      } catch (_) {}
    }
    return cloudinaryConfig;
  }

  Future<String> saveCloudinaryConfig(CloudinaryConfig config) async {
    _cloudinaryConfig = config;
    notifyListeners();
    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('portfolio_config')
            .doc('cloudinary')
            .set(config.toMap());
        return 'Cloudinary configuration saved to Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Saved locally (Firestore notice: $_lastFirestoreError)';
      }
    }
    return 'Cloudinary configuration saved locally.';
  }

  Future<String> updateProfile(ProfileData updatedProfile) async {
    _profile = updatedProfile;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('portfolio_config')
            .doc('profile')
            .set(updatedProfile.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Profile saved to Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Profile updated locally.';
  }

  // ===========================================================================
  // CRUD: CHAPTER I — EXPERIENCES & EDUCATIONS
  // ===========================================================================

  Future<String> upsertExperience(ExperienceItem item) async {
    final currentList = experiences;
    final id = item.id.isNotEmpty
        ? item.id
        : 'exp_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = item.copyWith(
      id: id,
      order: item.order > 0 ? item.order : (currentList.length + 1),
    );

    final updated = List<ExperienceItem>.of(currentList);
    final index = updated.indexWhere((e) => e.id == id);
    if (index >= 0) {
      updated[index] = normalized;
    } else {
      updated.add(normalized);
    }
    updated.sort((a, b) => a.order.compareTo(b.order));
    _experiences = updated;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('experiences')
            .doc(id)
            .set(normalized.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Work experience stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Experience updated locally.';
  }

  Future<String> deleteExperience(String id) async {
    _experiences = experiences.where((e) => e.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('experiences')
            .doc(id)
            .delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Deleted from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Removed locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Removed locally.';
  }

  Future<String> upsertEducation(EducationItem item) async {
    final currentList = educations;
    final id = item.id.isNotEmpty
        ? item.id
        : 'edu_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = item.copyWith(
      id: id,
      order: item.order > 0 ? item.order : (currentList.length + 1),
    );

    final updated = List<EducationItem>.of(currentList);
    final index = updated.indexWhere((e) => e.id == id);
    if (index >= 0) {
      updated[index] = normalized;
    } else {
      updated.add(normalized);
    }
    updated.sort((a, b) => a.order.compareTo(b.order));
    _educations = updated;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('educations')
            .doc(id)
            .set(normalized.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Education stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Education updated locally.';
  }

  Future<String> deleteEducation(String id) async {
    _educations = educations.where((e) => e.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('educations')
            .doc(id)
            .delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Deleted education from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Removed locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Removed locally.';
  }

  // ===========================================================================
  // CRUD: CHAPTER II — PLATFORMS & SKILLS
  // ===========================================================================

  Future<String> upsertPlatform(PlatformItem item) async {
    final currentList = platforms;
    final id = item.id.isNotEmpty
        ? item.id
        : 'plat_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = item.copyWith(
      id: id,
      order: item.order > 0 ? item.order : (currentList.length + 1),
    );

    final updated = List<PlatformItem>.of(currentList);
    final index = updated.indexWhere((p) => p.id == id);
    if (index >= 0) {
      updated[index] = normalized;
    } else {
      updated.add(normalized);
    }
    updated.sort((a, b) => a.order.compareTo(b.order));
    _platforms = updated;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('platforms')
            .doc(id)
            .set(normalized.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Platform stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Platform updated locally.';
  }

  Future<String> deletePlatform(String id) async {
    _platforms = platforms.where((p) => p.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('platforms')
            .doc(id)
            .delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Platform deleted from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Removed locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Removed locally.';
  }

  Future<String> upsertSkill(SkillItem item) async {
    final currentList = skills;
    final id = item.id.isNotEmpty
        ? item.id
        : 'skill_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = item.copyWith(
      id: id,
      order: item.order > 0 ? item.order : (currentList.length + 1),
    );

    final updated = List<SkillItem>.of(currentList);
    final index = updated.indexWhere((s) => s.id == id);
    if (index >= 0) {
      updated[index] = normalized;
    } else {
      updated.add(normalized);
    }
    updated.sort((a, b) => a.order.compareTo(b.order));
    _skills = updated;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('skills')
            .doc(id)
            .set(normalized.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Skill "${normalized.title}" stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Skill updated locally.';
  }

  Future<String> deleteSkill(String id) async {
    _skills = skills.where((s) => s.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance.collection('skills').doc(id).delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Skill deleted from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Removed locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Removed locally.';
  }

  // ===========================================================================
  // CRUD: CHAPTERS III & IV — PROJECTS
  // ===========================================================================

  Future<String> upsertProject(ProjectUtils project) async {
    final currentList = allProjects;
    final id = project.id.isNotEmpty
        ? project.id
        : 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = project.copyWith(
      id: id,
      order: project.order > 0 ? project.order : (currentList.length + 1),
    );

    final updated = List<ProjectUtils>.of(currentList);
    final index = updated.indexWhere((p) => p.id == id);
    if (index >= 0) {
      updated[index] = normalized;
    } else {
      updated.add(normalized);
    }
    updated.sort((a, b) => a.order.compareTo(b.order));
    _projects = updated;
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(id)
            .set(normalized.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Project "${normalized.title}" stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Updated locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Project updated locally.';
  }

  Future<String> deleteProject(String id) async {
    _projects = allProjects.where((p) => p.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(id)
            .delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Project deleted from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Removed locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Removed locally.';
  }

  // ===========================================================================
  // CRUD: EPILOGUE — VISITOR CONTACT MESSAGES
  // ===========================================================================

  Future<String> submitContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final msg = ContactMessage(
      id: id,
      name: name.trim(),
      email: email.trim(),
      message: message.trim(),
      createdAt: DateTime.now(),
      isRead: false,
    );

    _messages = [msg, ...messages];
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(id)
            .set(msg.toMap());
        _lastFirestoreError = null;
        notifyListeners();
        return 'Message stored in Cloud Firestore!';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Message saved locally (Firestore notice: $_lastFirestoreError)';
      }
    }
    return 'Message saved to inbox.';
  }

  Future<void> markMessageRead(String id, bool isRead) async {
    final updated = List<ContactMessage>.of(messages);
    final index = updated.indexWhere((m) => m.id == id);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(isRead: isRead);
      _messages = updated;
      notifyListeners();
    }

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(id)
            .update({'isRead': isRead});
        _lastFirestoreError = null;
        notifyListeners();
      } catch (e) {
        _recordFirestoreError(e);
      }
    }
  }

  Future<String> deleteMessage(String id) async {
    _messages = messages.where((m) => m.id != id).toList();
    notifyListeners();

    if (_isFirebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(id)
            .delete();
        _lastFirestoreError = null;
        notifyListeners();
        return 'Message deleted from Cloud Firestore.';
      } catch (e) {
        _recordFirestoreError(e);
        return 'Deleted locally, but Firestore failed: $_lastFirestoreError';
      }
    }
    return 'Message deleted.';
  }
}
