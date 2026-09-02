import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/knowledge_note.dart';

class KnowledgeNotifier extends StateNotifier<List<KnowledgeNote>> {
  KnowledgeNotifier() : super(_initialNotes());

  static List<KnowledgeNote> _initialNotes() {
    return [
      KnowledgeNote(
        id: 'note-1',
        title: 'Binary Tree Maximum Path Sum & Tree Recursion Patterns',
        category: 'DSA & Algorithms',
        tags: ['Trees', 'Recursion', 'Striver A2Z', 'LeetCode Hard'],
        linkedEntities: ['Step 13: Binary Trees', 'LeetCode 124'],
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        contentMarkdown: '''
# Binary Tree Maximum Path Sum (LeetCode 124)

## Core Insight
A path can turn at at most ONE node (the Highest Ancestor / LCA of the path).

## Bottom-Up Contribution Formula
For any node `curr`:
- Compute `leftGain = max(0, maxPathDown(curr.left))`
- Compute `rightGain = max(0, maxPathDown(curr.right))`
- Update global max: `globalMax = max(globalMax, curr.val + leftGain + rightGain)`
- Return to parent: `curr.val + max(leftGain, rightGain)`

```cpp
int maxGain(TreeNode* node, int& maxSum) {
    if (!node) return 0;
    int leftGain = max(maxGain(node->left, maxSum), 0);
    int rightGain = max(maxGain(node->right, maxSum), 0);
    int priceNewpath = node->val + leftGain + rightGain;
    maxSum = max(maxSum, priceNewpath);
    return node->val + max(leftGain, rightGain);
}
```
''',
      ),
      KnowledgeNote(
        id: 'note-2',
        title: 'GPU Shared Memory Bank Conflicts & Tiling Strategies',
        category: 'AI Systems Architecture',
        tags: ['GPU', 'CUDA', 'Triton', 'SRAM'],
        linkedEntities: ['FlashAttention Kernel', 'Milestone 2'],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        contentMarkdown: '''
# GPU Shared Memory Bank Conflicts

## Physical Hardware Layout
- NVIDIA Shared Memory is organized into 32 banks (4-byte words).
- If multiple threads in a warp access different words in the same bank simultaneously -> N-way serialization penalty.

## Mitigation Strategy: Padding & Swizzling
- Add a 1-element pad to column strides: `float smem[32][33];`
- Use XOR swizzling patterns in Triton to ensure thread IDs map to orthogonal memory banks.
''',
      ),
      KnowledgeNote(
        id: 'note-3',
        title: 'Raft Distributed Consensus: Leader Election & Log Replication',
        category: 'Distributed Systems',
        tags: ['Raft', 'Consensus', 'Distributed Systems'],
        linkedEntities: ['Distributed KV Store'],
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        contentMarkdown: '''
# Raft Consensus Protocol

## Key Invariants
1. **Election Safety**: At most one leader can be elected per term.
2. **Leader Append-Only**: A leader never overwrites or truncates its log; it only appends new entries.
3. **Log Matching**: If two logs contain an entry with the same index and term, then the logs are identical in all entries up through the given index.
''',
      ),
    ];
  }

  void addNote(KnowledgeNote note) {
    state = [note, ...state];
  }

  void updateNote(String id, String title, String markdown) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(
          title: title,
          contentMarkdown: markdown,
          updatedAt: DateTime.now(),
        );
      }
      return n;
    }).toList();
  }
}

final knowledgeProvider =
    StateNotifierProvider<KnowledgeNotifier, List<KnowledgeNote>>((ref) {
  return KnowledgeNotifier();
});
