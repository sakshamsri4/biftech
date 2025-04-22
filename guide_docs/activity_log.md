# Biftech Project Activity Log

This file tracks all development activities, issues encountered, solutions implemented, and lessons learned throughout the Biftech Flutter project.

## [2023-04-22 | 14:45 PM]
- ✅ Created project structure with `guide_docs` folder
- ✅ Added `activity_log.md` to track development progress
- ✅ Added `dev_rules.md` to establish development guidelines
- 📁 Files created:
  - guide_docs/activity_log.md
  - guide_docs/dev_rules.md
- 📝 Notes: Initial project setup complete with documentation structure

## [2023-04-22 | 14:47 PM]
- ✅ Created detailed project roadmap
- ✅ Added step-by-step implementation guide with time estimates
- ✅ Included module-specific test requirements
- 📁 Files created:
  - guide_docs/roadmap.md
- 📝 Notes: Roadmap provides clear direction for the two-day development sprint with specific action items and deliverables

## [2023-04-22 | 14:55 PM]
- ✅ Implemented Step 1: Created feature module directories
- ✅ Set up folder structure for auth, video_feed, flowchart, donation, and winner modules
- ✅ Added barrel files for easier imports
- ✅ Created shared directory for common widgets and models
- 📁 Files created:
  - lib/features/{auth,video_feed,flowchart,donation,winner}/{view,cubit,model}/
  - lib/features/{auth,video_feed,flowchart,donation,winner}/*.dart (barrel files)
  - lib/features/features.dart
  - lib/shared/{widgets,models}/
  - lib/shared/shared.dart
- 📝 Notes: Established a clean, modular structure following the feature-first architecture pattern

## [2023-04-22 | 15:00 PM]
- ❌ CRITICAL ERROR: Made changes directly on main branch, violating Git workflow rules
- 🔄 Created feature branch `feature/setup` and moved changes there
- 📁 Files changed: None (branch operation only)
- 📝 Lessons learned:
  1. Always create a feature branch before starting any work
  2. Follow Git workflow rules specified in dev_rules.md
  3. Double-check branch status before making any changes
  4. Add branch creation step explicitly in roadmap documentation

## [2023-04-22 | 15:30 PM]
- ✅ Implemented Step 2: Built Auth UI with NeoPop styling
- ✅ Created AuthCubit with proper state management (initial, loading, success, failure)
- ✅ Implemented form validation using Formz
- ✅ Created custom NeoTextField and NeoButton widgets
- ❌ Issue: Email regex pattern caused compilation errors due to single quote in the pattern
- 🔄 Fixed by removing the problematic character from the regex
- 📁 Files created/changed:
  - lib/features/auth/model/*.dart (auth_model, email, password, models)
  - lib/features/auth/cubit/*.dart (auth_cubit, auth_state)
  - lib/features/auth/view/*.dart (auth_page, auth_form)
  - lib/shared/widgets/*.dart (neo_text_field, neo_button)
  - lib/app/view/app.dart (updated to use AuthPage)
- 🧪 Tests added: test/features/auth/cubit/auth_cubit_test.dart with 10 test cases
- 📝 Lessons learned:
  1. Be careful with regex patterns, especially with special characters
  2. Use Formz for form validation to simplify state management
  3. Break down UI components into smaller, reusable widgets

## [2023-04-22 | 16:00 PM]
- ❌ CRITICAL ERROR: Committed code without testing it first
- ❌ Issue 1: NeoPopTextField and NeoPopButton components don't exist in the neopop package
- ❌ Issue 2: Barrel files for unimplemented features caused compilation errors
- ❌ Issue 3: Import directives were not sorted alphabetically
- ❌ Issue 4: Xcode project configuration issues prevented running on iOS simulator
- 🔄 Fixed NeoTextField by creating a custom implementation with standard Flutter widgets
- 🔄 Fixed NeoButton by using the correct NeoPopButton from the neopop package
- 🔄 Updated barrel files for unimplemented features with TODO comments
- 🔄 Sorted import directives alphabetically in all files
- 📁 Files changed:
  - lib/shared/widgets/neo_text_field.dart (reimplemented without neopop dependency)
  - lib/shared/widgets/neo_button.dart (fixed to use correct neopop components)
  - lib/features/{donation,flowchart,video_feed,winner}/*.dart (added TODOs)
  - Multiple files (fixed import ordering)
- 📝 Lessons learned:
  1. ALWAYS test code before committing, even if it seems correct
  2. Check package documentation thoroughly before using components
  3. Use placeholder files with proper TODOs for features to be implemented later
  4. Run flutter analyze regularly to catch issues early
  5. Document platform-specific setup requirements in dev_rules.md

## [2023-04-22 | 16:15 PM]
- ✅ Successfully ran the app on Chrome browser
- ✅ Created test_app.dart as an alternative entry point for testing
- ✅ Updated dev_rules.md with new sections:
  - Pre-Commit Checklist
  - Platform-Specific Setup
  - Documentation Standards
- 📁 Files created/changed:
  - lib/test_app.dart (new test entry point)
  - guide_docs/dev_rules.md (added new sections)
  - guide_docs/activity_log.md (updated with lessons learned)
- 📝 Lessons learned:
  1. Use web browser for initial testing to avoid platform-specific issues
  2. Create alternative entry points for testing specific features
  3. Document all issues and solutions immediately to avoid repeating mistakes

## [2023-04-22 | 16:30 PM]
- ❌ CRITICAL ERROR: Failed to test on iOS simulator where keyboard caused severe overflow issues
- ❌ Issue: Auth UI had overflow issues specifically when keyboard appeared on iOS devices
- ❌ Issue: Form elements were pushed off-screen and became inaccessible when typing
- ❌ Issue: No scrolling was implemented to handle keyboard appearance
- ❌ Issue: Responsiveness was not properly tested on different screen sizes
- ✅ Improved responsiveness of Auth UI components
- ✅ Added keyboard handling to prevent overflow issues
- ✅ Made UI elements adapt to different screen sizes
- 🔄 Solutions implemented:
  1. Used SingleChildScrollView to allow scrolling when keyboard appears on iOS
  2. Added conditional rendering to hide header when keyboard is visible
  3. Made text fields and buttons responsive based on screen width
  4. Added GestureDetector to dismiss keyboard when tapping outside inputs
  5. Used SafeArea to handle system UI elements like notches
  6. Implemented proper constraints to prevent overflow on smaller screens
- 📁 Files changed:
  - lib/features/auth/view/auth_form.dart (improved responsiveness)
  - lib/features/auth/view/auth_page.dart (added keyboard handling)
  - lib/shared/widgets/neo_text_field.dart (made responsive)
  - lib/shared/widgets/neo_button.dart (made responsive)
- 📝 Lessons learned:
  1. ALWAYS test UI on ALL target platforms (Android, iOS, web) before committing
  2. iOS keyboard behavior is different from Android and requires special handling
  3. Use MediaQuery.viewInsets.bottom to detect keyboard height
  4. Always implement scrolling in forms to handle keyboard appearance
  5. Test with the smallest supported screen size with keyboard open
  6. Document platform-specific issues and solutions in detail
  7. Never assume a UI that works on one platform will work on all platforms

## Template for Future Entries

```
## [YYYY-MM-DD | HH:MM AM/PM]
- ✅ Completed tasks
- ❌ Issues encountered
- 🔁 Solutions implemented
- 📁 Files changed: path/to/file1.dart, path/to/file2.dart
- 🧪 Tests added: test/path/to/test_file.dart with X test cases
- 📝 Lessons learned or things to improve
```
