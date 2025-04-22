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

## [2023-04-22 | 17:00 PM]
- ❌ CRITICAL ERROR: Implemented incomplete authentication system
- ❌ Issue: Created only login functionality without sign-up or forgot password
- ❌ Issue: Misinterpreted requirements and delivered partial implementation
- ❌ Issue: Failed to follow standard authentication patterns
- ❌ Issue: Roadmap was incomplete and missing critical auth components
- 🔄 Solutions to implement:
  1. Update roadmap to include complete authentication requirements
  2. Implement Sign Up screen with proper validation
  3. Implement Forgot Password functionality
  4. Add navigation between different auth screens
  5. Enhance AuthCubit to handle different authentication modes
  6. Update tests to cover all authentication scenarios
- 📁 Files to change:
  - guide_docs/roadmap.md (updated with complete auth requirements)
  - lib/features/auth/view/ (add sign_up_page.dart and forgot_password_page.dart)
  - lib/features/auth/cubit/ (enhance to handle multiple auth modes)
  - test/features/auth/ (expand test coverage)
- 📝 Lessons learned:
  1. Always implement complete features, not partial functionality
  2. Follow standard patterns for common features like authentication
  3. Question and clarify requirements that seem incomplete
  4. Consider user flows and navigation between related screens
  5. Review roadmap critically to identify missing components
  6. Don't rush implementation at the expense of completeness

## [2023-04-22 | 17:30 PM]
- ✅ Implemented complete authentication system with sign-up and forgot password
- ✅ Enhanced AuthCubit to handle different authentication modes (login, sign-up, forgot password)
- ✅ Added new form models: Name and ConfirmedPassword with validation
- ✅ Created Sign Up page with name, email, password, and confirm password fields
- ✅ Created Forgot Password page with email field
- ✅ Added navigation between auth screens
- ✅ Updated tests to cover all authentication scenarios
- 📁 Files created/changed:
  - lib/features/auth/model/name.dart (new model for name validation)
  - lib/features/auth/model/confirmed_password.dart (new model for password confirmation)
  - lib/features/auth/cubit/auth_state.dart (enhanced with auth modes and new fields)
  - lib/features/auth/cubit/auth_cubit.dart (updated to handle different auth modes)
  - lib/features/auth/view/auth_form.dart (added navigation to other auth screens)
  - lib/features/auth/view/sign_up_page.dart (new page for user registration)
  - lib/features/auth/view/forgot_password_page.dart (new page for password recovery)
  - test/features/auth/cubit/auth_cubit_test.dart (expanded test coverage)
- 🧪 Tests added: Comprehensive tests for all auth modes (login, sign-up, forgot password)
- 📝 Implementation details:
  1. Used BlocProvider.value to share the same AuthCubit instance across auth screens
  2. Added AuthMode enum to track the current authentication mode
  3. Implemented proper validation for all input fields
  4. Added success messages for each authentication scenario
  5. Ensured responsive design for all auth screens

## [2023-04-22 | 18:00 PM]
- ❌ CRITICAL ERROR: Provider-related error when navigating between auth screens
- ❌ Issue: ProviderNotFoundException when trying to access AuthCubit in sign-up and forgot password pages
- ❌ Issue: Attempted to use context.read<AuthCubit>() in initState which is not allowed
- ❌ Issue: Navigation implementation didn't properly share the AuthCubit instance
- ✅ Implemented proper navigation system with shared AuthCubit
- ✅ Refactored AuthPage to manage all auth screens with a single AuthCubit instance
- ✅ Removed direct navigation between screens and used callbacks instead
- 🔄 Solutions implemented:
  1. Converted AuthPage to StatefulWidget to maintain a single AuthCubit instance
  2. Used BlocProvider.value to properly share the AuthCubit
  3. Implemented a tab-like navigation system with state management
  4. Removed initState calls to changeMode in child widgets
  5. Added callback functions for navigation between screens
- 📁 Files changed:
  - lib/features/auth/view/auth_page.dart (refactored to manage all auth screens)
  - lib/features/auth/view/auth_form.dart (updated to use callbacks for navigation)
  - lib/features/auth/view/sign_up_page.dart (removed direct navigation and initState call)
  - lib/features/auth/view/forgot_password_page.dart (removed direct navigation and initState call)
- 📝 Lessons learned:
  1. Never use context.read<T>() in initState as the provider may not be available yet
  2. When sharing state between screens, use a parent widget to manage the state
  3. Use BlocProvider.value to share existing instances of Blocs/Cubits
  4. Prefer callbacks for navigation between screens that share state
  5. Always test navigation flows thoroughly, especially with state management

## [2023-04-22 | 19:00 PM]
- ✅ Implemented Hive storage for authentication data
- ✅ Created UserModel with Hive adapter for data persistence
- ✅ Implemented AuthRepository for authentication operations
- ✅ Added AuthService for initializing Hive and providing the repository
- ✅ Updated AuthCubit to use the repository for authentication
- ✅ Updated tests to use mock repository
- 🔄 Implementation details:
  1. Added Hive dependencies to pubspec.yaml
  2. Created UserModel with Hive annotations for storage
  3. Implemented AuthRepository with CRUD operations for users
  4. Created AuthService to initialize Hive and provide the repository
  5. Updated AuthCubit to use the repository for login, sign-up, and forgot password
  6. Updated bootstrap.dart to initialize the AuthService
  7. Updated tests to use mock repository
- 📁 Files created/changed:
  - lib/features/auth/model/user_model.dart (new model for Hive storage)
  - lib/features/auth/repository/auth_repository.dart (new repository for auth operations)
  - lib/features/auth/service/auth_service.dart (new service for Hive initialization)
  - lib/features/auth/cubit/auth_cubit.dart (updated to use repository)
  - lib/features/auth/view/auth_page.dart (updated to provide repository)
  - lib/bootstrap.dart (updated to initialize AuthService)
  - pubspec.yaml (added Hive dependencies)
  - test/features/auth/cubit/auth_cubit_test.dart (updated to use mock repository)
- 📝 Lessons learned:
  1. Use Hive for efficient local storage in Flutter
  2. Implement proper repository pattern for data access
  3. Initialize services before running the app
  4. Use dependency injection to provide repositories to cubits
  5. Mock repositories in tests to isolate components

## [2023-04-22 | 19:30 PM]
- ❌ CRITICAL ERROR: Flutter binding not initialized before accessing platform services
- ❌ Issue: Attempted to initialize Hive without calling WidgetsFlutterBinding.ensureInitialized()
- ❌ Issue: Received error: "Binding has not yet been initialized" when running the app
- ❌ Issue: Platform services (file system, etc.) were not available for Hive to use
- ✅ Fixed by adding WidgetsFlutterBinding.ensureInitialized() call in bootstrap.dart
- 🔄 Solution implemented:
  1. Added WidgetsFlutterBinding.ensureInitialized() call before any platform service access
  2. Ensured this call happens before Hive initialization
- 📁 Files changed:
  - lib/bootstrap.dart (added binding initialization)
- 📝 Lessons learned:
  1. ALWAYS call WidgetsFlutterBinding.ensureInitialized() in main() before accessing any platform services
  2. This is especially important for plugins that access file system, camera, etc.
  3. The binding connects Dart code to the underlying platform services
  4. This is a fundamental requirement for Flutter plugins and should never be overlooked
  5. The error message "Binding has not yet been initialized" is a clear indicator of this issue

## [2023-04-22 | 20:00 PM]
- ❌ Issue: Password fields lacked visibility toggle, making it difficult for users to verify input
- ❌ Issue: Sign-up and forgot password screens had commented-out AppBars, causing UI to black out
- ✅ Added password visibility toggle to all password fields
- ✅ Fixed sign-up and forgot password screens by uncommenting AppBars
- 🔄 Solutions implemented:
  1. Converted NeoTextField to StatefulWidget to manage password visibility state
  2. Added visibility toggle icon button for password fields
  3. Uncommented AppBars in sign-up and forgot password screens
- 📁 Files changed:
  - lib/shared/widgets/neo_text_field.dart (added password visibility toggle)
  - lib/features/auth/view/sign_up_page.dart (fixed AppBar)
  - lib/features/auth/view/forgot_password_page.dart (fixed AppBar)
- 📝 Lessons learned:
  1. Always provide password visibility toggle for better user experience
  2. Be careful when commenting out UI elements during development
  3. Test all screens thoroughly on actual devices
  4. Pay attention to basic usability features that users expect

## [2023-04-22 | 20:30 PM]
- ❌ CRITICAL ERROR: HiveError during login process
- ❌ Issue: Error message: "The same instance of an HiveObject cannot be stored with two different keys"
- ❌ Issue: Attempting to store the same UserModel instance with both email and 'current_user' keys
- ✅ Fixed by creating a copy of the user object before storing as current user
- 🔄 Solution implemented:
  1. Modified loginUser method in AuthRepository to create a new UserModel instance
  2. Used the copy for the 'current_user' key while keeping the original for the email key
- 📁 Files changed:
  - lib/features/auth/repository/auth_repository.dart (fixed Hive storage issue)
- 📝 Lessons learned:
  1. Hive objects cannot be stored with multiple keys in the same box
  2. Always create copies of objects when storing with different keys
  3. Pay attention to error logs to identify specific Hive constraints
  4. Test authentication flows with real data to catch these issues

## [2023-04-22 | 21:00 PM]
- ✅ Created home page with bottom navigation and user profile
- ✅ Implemented navigation from login to home page
- ✅ Added placeholder content for main features
- ✅ Implemented logout functionality
- 🔄 Implementation details:
  1. Created HomePage with bottom navigation for different sections
  2. Added user profile display with welcome message
  3. Implemented featured content and recent activity sections
  4. Added placeholder tabs for Videos, Flowchart, and Donation features
  5. Connected authentication flow to navigate to home page after login
  6. Added logout functionality to return to login screen
- 📁 Files created/changed:
  - lib/features/home/view/home_page.dart (new home page with bottom navigation)
  - lib/features/home/view/view.dart (barrel file for home views)
  - lib/features/home/home.dart (barrel file for home feature)
  - lib/app/view/app.dart (added routes for navigation)
  - lib/features/auth/view/auth_form.dart (enabled navigation to home page)
- 📝 Implementation notes:
  1. Used bottom navigation to provide access to all main features
  2. Displayed user information from Hive storage
  3. Created responsive layout that works on different screen sizes
  4. Added placeholder content for features to be implemented later

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
