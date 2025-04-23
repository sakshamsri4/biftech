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

### 🔹 Step 3: Build Basic Video Feed UI (1.5 hrs)
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

### 🔹 Step 3.1: Enhanced Video Feed UI (3 hrs)
**Branch:** Continue on `feature/video_feed` branch
**Location:** `features/video_feed/view/video_feed_page.dart`
**Action:**
- Upgrade the scrollable feed with feature-rich video cards:
  - Add video player with play button overlay
  - Implement inline video playback on tap
  - Show duration ("2 min")
  - Add "Participate" button that navigates to flowchart discussion
  - Ensure only one video plays at a time (auto-pause others)

**Use:** `video_player` or `Chewie` package
**Test:** Test video playback and auto-pause functionality
**Log in:** Video player integration challenges

### 🔹 Step 3.2: Upload Video Feature (2 hrs)
**Branch:** Continue on `feature/video_feed` branch
**Location:** `features/video_feed/view/upload_video_page.dart`
**Action:**
- Create "Upload Your Idea" button at top/bottom of feed
- Implement upload video screen with:
  - Thumbnail picker (optional)
  - Title input field
  - Creator name input
  - Duration input
  - Description/context input
  - Video picker from gallery/camera
- Implement upload flow:
  - Validate required fields
  - Save locally or mock upload
  - Navigate back to feed and insert new video at top

**Use:** `image_picker` for thumbnails and videos
**Test:** Test form validation and video upload flow
**Log in:** File picking and validation challenges

### 🔹 Step 3.3: Performance Optimization (1.5 hrs)
**Branch:** Continue on `feature/video_feed` branch
**Location:** `features/video_feed/view/video_feed_page.dart`
**Action:**
- Implement controller pool for video players (Map<int, VideoPlayerController>)
- Add lazy loading with ListView.builder
- Implement cached_network_image for thumbnails
- Add error handling for video playback
- Optimize memory usage by disposing controllers when not needed

**Use:** `cached_network_image` package
**Test:** Test performance with multiple videos
**Log in:** Memory management and performance optimization notes

### 🔹 Step 4: Build Flowchart UI and Interaction (4 hrs)
**Branch:** `git checkout -b feature/flowchart`
**Location:** `features/flowchart/view/flowchart_page.dart`
**Action:**
- Show a root idea node (the video topic)
- Implement expandable/collapsible challenge nodes
- Display comments under each node
- Create a visual discussion tree with:
  - Root node (the idea or topic)
  - Comment threads for each node
  - Challenge branches forming new nodes under the parent
  - Expandable/collapsible tree structure

**Use:** `flutter_treeview` for visualization
**State mgmt:** `FlowchartCubit` manages tree structure
**Data:** Use `NodeModel` with:
```dart
String id;
String text;
double donation;
List<String> comments;
List<NodeModel> challenges;
DateTime createdAt;
```

**Example JSON Structure:**
```json
{
  "id": "root",
  "text": "Electric Vehicles are the future",
  "donation": 0,
  "comments": ["Agreed!", "But what about battery waste?"],
  "challenges": [
    {
      "id": "challenge1",
      "text": "Battery production pollutes heavily",
      "donation": 20,
      "comments": ["Exactly!", "Data proves this."],
      "challenges": []
    }
  ],
  "createdAt": "2023-04-25T12:00:00Z"
}
```

**Test:**
- Unit test for adding and expanding nodes
- Test for tree structure manipulation
- Test for proper node rendering

**Log in:** Challenges with recursive state updates and tree visualization

### 🔹 Step 5: Add Comment/Challenge Modal (2 hrs)
**Branch:** Continue on `feature/flowchart` branch
**Action:**
- Implement "💬 Comment" button on each node:
  - Tapping opens a modal with TextField for comment
  - Comments are displayed inline under the node
- Implement "⚔️ Challenge" button on each node:
  - Tapping opens a modal with TextField for argument
  - Include slider or TextField for donation amount (optional, mock only)
  - After submission, new node appears as a child of the challenged node
  - Tree updates in real-time locally

**Use:**
- `showModalBottomSheet` for input modals
- NeoPopButton for comment and challenge buttons

**Store in:** `FlowchartCubit` with methods:
- `addComment(String nodeId, String comment)`
- `addChallenge(String parentNodeId, String text, double donation)`

**Test:**
- Test Cubit state after adding comment
- Test Cubit state after adding challenge
- Test UI updates after state changes

**Log in:**
- Donation parsing or input validation bugs
- Challenges with tree structure updates

## 📆 Day 2 – Logic + Mock Features + Polish

### 🔹 Step 6: Add Donation Flow (1.5 hrs)
**Branch:** `git checkout -b feature/donation`
**Location:** `features/donation/view/donation_modal.dart`
**Action:**
- Create donation input UI with:
  - Slider or TextField for amount selection
  - Validation for minimum amount (>= ₹1.0)
  - Visual feedback for selected amount
- Implement mock donation storage:
  - Store donation amount in NodeModel.donation
  - No real PayPal integration - just mock UI
  - Display donation amount on challenge nodes

**Use:**
- NeoPopSlider or custom slider for amount selection
- Form validation for donation amount

**Test:**
- Test that donation updates the correct node
- Test validation logic for minimum donation
- Test UI updates after donation

**Log in:** Edge cases and validation challenges

### 🔹 Step 7: Decision Logic and Winner Declaration (2.5 hrs)
**Branch:** `git checkout -b feature/winner`
**Location:** `features/winner/cubit/winner_cubit.dart`
**Action:**
- Implement "Declare Winner" button (mocking 24-hour evaluation)
- Create evaluation algorithm:
  - Calculate score for each node: score = totalDonation + numberOfComments
  - Traverse the entire flowchart tree recursively
  - Select node with highest score as winner
  - Use tiebreakers: first submitted or deepest challenge
- Implement winner declaration UI:
  - Show dialog with title "Winning Argument"
  - Display text of winning node
  - Show donation earned (based on mock input)
  - Add "View Distribution" button
- Implement donation distribution logic (mock):
  - Sum all donations in the tree
  - Distribute as: 60% to winning argument, 20% to app contribution, 20% to platform margin
  - Display distribution in a pie chart (optional)

**Use:**
- Recursive tree traversal for evaluation
- `fl_chart` or `syncfusion_flutter_charts` for pie chart (optional)

**Test:**
- Test winner selection logic with various sample data
- Test score calculation (comments + donations)
- Test distribution percentages
- Test tiebreaker scenarios

**Log in:**
- Challenges with recursive tree traversal
- Handling edge cases (ties, empty tree)

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

## 📦 Dependencies

| Package | Purpose |
|---------|--------|
| flutter_bloc | State management |
| equatable | Value equality |
| go_router | Navigation |
| hive | Local storage |
| neopop | UI components |
| video_player | Video playback |
| Chewie | Video player UI |
| cached_network_image | Image caching |
| image_picker | Media selection |
| flutter_treeview | Flowchart visualization |
| fl_chart | Pie chart for donation distribution (optional) |
| syncfusion_flutter_charts | Alternative for charts (optional) |

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
| Video Feed | Widget test for rendering cards, video playback tests, upload form validation, controller management tests |
| Flowchart | Cubit logic test (add node, comment), tree structure tests, node rendering tests |
| Donation | Validate donation input logic, test donation storage, test UI updates |
| Winner | Test winner calculation logic, test score calculation, test distribution percentages, test tiebreaker scenarios |
| Theme | Toggle test, default value check |
