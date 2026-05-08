# Profile Module

This module provides comprehensive profile management for the Leyu Mobile app, following the same clean architecture and form handling patterns used across the codebase.

## Components

### Pages

- **MainProfileScreen** (`presentation/pages/main_profile_screen.dart`)
  - Primary profile screen with bottom navigation
  - Route: `/profilePage`

- **ProfilePage** (`presentation/pages/profile_page.dart`)
  - Profile header and content view

- **EditProfilePage** (`presentation/pages/edit_profile_page.dart`)
  - Editable profile form
  - Route: `/editProfile`

- **ChangePasswordPage** (`presentation/pages/change_password_page.dart`)
  - Password change form
  - Route: `/changePassword`

### Widgets

- **ProfileMainWidget** — Profile info, stats, KYC status, and navigation options
- **EditProfileWidget** — Form for editing first/middle/last name and email
- **ChangePasswordWidget** — Current and new password form
- **KycStatusWidget** — Displays KYC verification status with re-upload option
- **ScoreDisplayWidget** — Shows contributor score and dataset counts
- **BottomNavigationWidget** — Shared bottom nav bar

### Controllers

- **ProfileController** (`presentation/controllers/profile_controller.dart`)
  - Loads and manages all profile state
  - Handles profile picture upload (camera or gallery)
  - Handles national ID upload with bottom sheet UI
  - Handles referral code submission
  - Manages KYC status display
  - Handles logout (clears storage + OneSignal)

### Bindings

- **ProfileBinding** (`presentation/bindings/profile_binding.dart`)
  - Wires `ProfileRemoteDataSource`, `ProfileRepository`, `ProfileUseCase`, and `ProfileController`

## Features

### Profile Display

- Profile picture with camera overlay (tap to change)
- Full name, phone, and active/inactive status badge
- Contributor score and dataset statistics (total / approved)
- KYC status indicator with re-upload sheet for rejected/pending IDs
- Navigation options: Edit Profile, Change Password, Referral Code, Logout

### Profile Editing

Editable fields (via `PUT /iam/users/me`):
- First name, middle name, last name, email

Read-only fields (displayed but not editable):
- Phone number, gender, date of birth, language, dialect

### Profile Picture Upload

- Source selection bottom sheet (camera or gallery)
- Images resized to max 512×512 at 80% quality before upload
- Uploads via `PUT /iam/users/profile` (multipart `image` field)
- Updates home controller's cached profile picture on success

### KYC (National ID)

- Displays current KYC status: `pending`, `under_review`, `approved`, `rejected`
- Re-upload sheet available for rejected or pending states
- Uploads via `PATCH /iam/users/national_id` (multipart `image` field)
- Status transitions to `under_review` immediately after successful upload

### Referral Code

- Bottom sheet with text input (auto-uppercased)
- Submits via `PATCH /iam/users/referral_code`
- Option hidden once user has already been referred (`isReferred == true`)

### Change Password

- Requires current password and new password
- Calls `PUT /iam/users/change-password`

### Preferred Language

- Updated via `PATCH /iam/users/preferred-language` with `language_key`
- Silently fails — language change is best-effort

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/iam/users/me` | Fetch profile |
| `PUT` | `/iam/users/me` | Update name/email |
| `PUT` | `/iam/users/profile` | Upload profile picture |
| `PUT` | `/iam/users/change-password` | Change password |
| `PATCH` | `/iam/users/national_id` | Upload national ID |
| `PATCH` | `/iam/users/referral_code` | Apply referral code |
| `PATCH` | `/iam/users/preferred-language` | Update preferred language |

## Reactive State

Key observables in `ProfileController`:

```dart
RxBool isLoadingProfile
RxString profileName, profileEmail, profilePhone, profileImage
RxString profileGender, profileBirthDate, profileLanguage, profileDialect
RxInt profileScore, totalDatasetCount, approvedDatasetCount
Rxn<KycStatus> kycStatus
RxBool isReferred
RxBool isUploadingProfilePicture, isUploadingNationalId
RxBool isEditingProfile, isChangingPassword, isApplyingReferral
```

## Usage

```dart
// Navigate to profile
Get.toNamed(AppRoutes.profilePage);

// Navigate to edit profile
Get.toNamed(AppRoutes.editProfile);

// Navigate to change password
Get.toNamed(AppRoutes.changePassword);
```

## Dependencies

- **Auth Module**: `User` model (shared entity for profile data)
- **Home Module**: `HomeController` (syncs profile picture and name after edits)
- **Core Widgets**: `InputBox`, `Button`, `ImagePickerWidget`
- **Core Services**: `OneSignalService` (logout), `LocalStorage` (cache clear + name update)
- **GetX**: State management and navigation
- **Dio**: HTTP requests and multipart uploads
- **image_picker**: Camera and gallery access
