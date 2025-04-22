# Biftech App - Development Roadmap

This roadmap outlines the step-by-step implementation plan for the Biftech Flutter application, broken down into phases, modules, and specific action items.

## 📆 Day 1 – Setup, Core UI & Flow

### 🔹 Step 1: Define Feature Modules (30 min)
**Action:**
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

### 🔹 Step 2: Build the Auth UI (1 hr)
**Location:** `features/auth/view/auth_page.dart`  
**Action:**
- Create a login screen with:
  - Email, password input (`NeoTextField`)
  - Login button (`NeoButton`)
  - Dummy validation

**State mgmt:** `AuthCubit` with states: initial, loading, success, failure  
**Test:** `test/features/auth/cubit/auth_cubit_test.dart` – test dummy login  
**Log in:** What went wrong (validation, state) + how fixed

### 🔹 Step 3: Build Video Feed UI (1.5 hrs)
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
**Location:** `features/donation/view/donation_modal.dart`  
**Action:**
- Input donation amount + argument
- Validate >= ₹1.0
- Append to node

**Test:** Add donation updates the correct node  
**Log in:** Edge case test results

### 🔹 Step 7: Winner Logic (1.5 hrs)
**Location:** `features/winner/cubit/winner_cubit.dart`  
**Action:**
- Add "Declare Winner" button
- Traverse flowchart, find node with:
  - Most donation + most comments
  - Show winner in dialog

**Test:** Logic test with sample data  
**Log in:** Conflict between ties or empty case

### 🔹 Step 8: Theme, Responsiveness, Minor Polish (1.5 hrs)
**Action:**
- Add theme toggle using `ThemeCubit`
- Test layout on different sizes
- Add animations (optional via `animated_container`, `lottie`)

**Test:** Widget test for theme switch  
**Log in:** Theme persistence issue

### 🔹 Step 9: README + Activity Summary (1 hr)
**Action:**
- Write README with:
  - Setup
  - Features
  - Known issues
  - Test coverage

**Optional:** Add .md snapshot of flowchart structure

### 🔹 Step 10: Record Video (30 min)
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
