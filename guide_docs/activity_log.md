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
