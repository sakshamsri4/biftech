# Biftech App - Development Roadmap

This roadmap outlines the step-by-step implementation plan for the Biftech Flutter application, broken down into phases, modules, and specific action items.

## 🚨 IMPORTANT: Git Workflow

Before starting any development work:
1. **ALWAYS create a feature branch** from main using the naming convention `feature/<module_name>`
2. Make all changes on the feature branch, never directly on main
3. Commit regularly with descriptive messages using prefixes (feat, fix, refactor, etc.)
4. When complete, create a PR for review
5. After approval, squash and merge to main

This workflow must be followed for all development tasks.

## 📆 Day 1 – Setup, Core UI & Flow

### 🔹 Step 1: Define Feature Modules (30 min)
**Action:**
- Create feature branch: `git checkout -b feature/setup`
- In `lib/features/`, create:
  ```
  auth/
  video_feed/
  flowchart/
  donation/
  winner/
  ```
- Inside each: `view/`, `cubit/`, `model/`

**Log in:** `activity_log.md`
**Rule Ref:** Folder rules from `dev_rules.md`

### 🔹 Step 2: Build the Auth UI (2 hrs)
**Branch:** `git checkout -b feature/auth`
**Location:** `features/auth/view/auth_page.dart`
**Action:**
- Create a complete authentication system with:
  - Login screen:
    - Email, password input (`NeoTextField`)
    - Login button (`NeoButton`)
    - "Forgot Password" link
    - "Sign Up" link
  - Sign Up screen:
    - Name, email, password, confirm password inputs
    - Sign Up button
    - "Back to Login" link
  - Forgot Password screen:
    - Email input
    - Submit button
    - "Back to Login" link
  - Comprehensive validation for all fields
  - Proper navigation between screens

**State mgmt:**
- `AuthCubit` with states: initial, loading, success, failure
- Handle different auth modes (login, signup, forgot password)
- Proper error handling and validation for each mode

**Test:**
- `test/features/auth/cubit/auth_cubit_test.dart` – test all auth modes
- Test validation logic for all input fields
- Test navigation between different auth screens

**Log in:** What went wrong (validation, state, navigation) + how fixed

### 🔹 Step 3: Build Video Feed UI (1.5 hrs)
**Branch:** `git checkout -b feature/video_feed`
**Location:** `features/video_feed/view/video_feed_page.dart`
**Action:**
- Create dummy model `VideoModel`
- Display scrollable cards with:
  - Title, creator, views
  - Tap navigates to `/flowchart/:id`

**Use:** `NeoCard`, mock data from `assets/json/videos.json`
**Test:** Widget test – renders 3 dummy videos
**Log in:** JSON parsing issue or UI polish notes

### 🔹 Step 4: Build Flowchart UI (3 hrs)
**Branch:** `git checkout -b feature/flowchart`
**Location:** `features/flowchart/view/flowchart_page.dart`
**Action:**
- Show a root idea node
- Expandable/collapsible challenge nodes
- Comments under each

**Use:** `flutter_treeview`
**State mgmt:** `FlowchartCubit` manages tree structure
**Data:** Use `NodeModel` with:
```dart
String id;
String text;
double donation;
List<NodeModel> challenges;
List<String> comments;
```

**Test:** Add + expand nodes logic unit test
**Log in:** Challenge: recursive state updates

### 🔹 Step 5: Add Comment/Challenge Modal (1.5 hrs)
**Branch:** Continue on `feature/flowchart` branch
**Action:**
- Tap "Comment" → input modal
- Tap "Challenge" → modal with:
  - Argument
  - Optional donation

**Use:** `showModalBottomSheet`
**Store in:** `FlowchartCubit`
**Test:** Cubit state after comment/challenge
**Log in:** Donation parsing or input validation bugs

## 📆 Day 2 – Logic + Mock Features + Polish

### 🔹 Step 6: Add Donation Flow (1 hr)
**Branch:** `git checkout -b feature/donation`
**Location:** `features/donation/view/donation_modal.dart`
**Action:**
- Input donation amount + argument
- Validate >= ₹1.0
- Append to node

**Test:** Add donation updates the correct node
**Log in:** Edge case test results

### 🔹 Step 7: Winner Logic (1.5 hrs)
**Branch:** `git checkout -b feature/winner`
**Location:** `features/winner/cubit/winner_cubit.dart`
**Action:**
- Add "Declare Winner" button
- Traverse flowchart, find node with:
  - Most donation + most comments
  - Show winner in dialog

**Test:** Logic test with sample data
**Log in:** Conflict between ties or empty case

### 🔹 Step 8: Theme, Responsiveness, Minor Polish (1.5 hrs)
**Branch:** `git checkout -b feature/theme`
**Action:**
- Add theme toggle using `ThemeCubit`
- Test layout on different sizes
- Add animations (optional via `animated_container`, `lottie`)

**Test:** Widget test for theme switch
**Log in:** Theme persistence issue

### 🔹 Step 9: README + Activity Summary (1 hr)
**Branch:** `git checkout main` (documentation updates can go directly to main)
**Action:**
- Write README with:
  - Setup
  - Features
  - Known issues
  - Test coverage

**Optional:** Add .md snapshot of flowchart structure

### 🔹 Step 10: Record Video (30 min)
**Branch:** N/A (no code changes)
**Action:**
- Use simulator + voice-over
- Show login → feed → flowchart → challenge → winner

## 📦 Final File Layout Reference

```
lib/
├── app/
├── bootstrap/
├── features/
│   ├── auth/
│   ├── video_feed/
│   ├── flowchart/
│   ├── donation/
│   ├── winner/
├── shared/
│   ├── widgets/
│   ├── models/
├── l10n/
test/
├── features/
```

## ✅ Tests Required Per Module

| Module | Tests |
|--------|-------|
| Auth | Cubit test (success, fail login) |
| Video Feed | Widget test for rendering cards |
| Flowchart | Cubit logic test (add node, comment) |
| Donation | Validate donation input logic |
| Winner | Test winner calculation logic |
| Theme | Toggle test, default value check |
