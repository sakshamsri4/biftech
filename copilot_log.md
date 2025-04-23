## [2025-04-24 | 15:30 PM]
- ✅ Fixed navigation and state management in the comments popup
- ❌ Issue: Add Comment button in CommentsPopup navigating outside of flowchart
- ❌ Issue: "Cannot emit new states after calling close" errors when using FlowchartCubit after leaving the flowchart
- 🔄 Solutions implemented:
  1. Added context property to FlowchartCubit to store the flowchart's BuildContext
  2. Modified FlowchartView to store its context in the cubit during initialization
  3. Implemented check to detect if cubit is closed before attempting to use it
  4. Updated _showCommentModal in CommentsPopup to use the correct context from cubit
  5. Enhanced CommentModal to check if cubit is closed before adding comments
  6. Added fallback error handling for when the cubit is closed
- 📁 Files changed:
  - lib/features/flowchart/cubit/flowchart_cubit.dart
  - lib/features/flowchart/view/flowchart_page.dart
  - lib/features/flowchart/view/widgets/comments_popup.dart
  - lib/features/flowchart/view/widgets/comment_modal.dart
- 🧪 Tests added: None for this specific fix.
- 📝 Lessons learned:
  1. Always check if a cubit is closed before attempting to emit states
  2. Use a cubit's stream.listen() with onDone() to detect when a cubit is closed
  3. Store and use the correct context for navigation between modals
  4. Add mounted checks and error handling for asynchronous operations
  5. Use post-frame callbacks when navigating between dialogs and modals
  6. Log errors with proper context for easier debugging
  7. Verify all navigation flows to ensure they use the correct context