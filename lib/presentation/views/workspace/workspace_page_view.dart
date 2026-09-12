import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/workspace_page.dart';
import '../../providers/workspace_provider.dart';

class WorkspacePageView extends ConsumerStatefulWidget {
  final String pageId;

  const WorkspacePageView({
    super.key,
    required this.pageId,
  });

  @override
  ConsumerState<WorkspacePageView> createState() => _WorkspacePageViewState();
}

class _WorkspacePageViewState extends ConsumerState<WorkspacePageView> {
  late TextEditingController _titleController;
  final Map<String, TextEditingController> _blockControllers = {};

  final List<String> _coverOptions = [
    'cyan_indigo',
    'emerald_teal',
    'amber_rose',
    'violet_dusk',
    'obsidian',
  ];

  final Map<String, IconData> _availableIcons = {
    'article': Icons.article_outlined,
    'code': Icons.code_rounded,
    'terminal': Icons.terminal_rounded,
    'bookmark': Icons.bookmark_border_rounded,
    'folder': Icons.folder_outlined,
    'school': Icons.school_outlined,
    'target': Icons.adjust_rounded,
    'rocket': Icons.rocket_launch_outlined,
    'bolt': Icons.bolt_rounded,
    'storage': Icons.storage_rounded,
    'psychology': Icons.psychology_outlined,
    'tune': Icons.tune_rounded,
    'star': Icons.star_border_rounded,
    'menu_book': Icons.menu_book_outlined,
    'checklist': Icons.checklist_rounded,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _blockControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getControllerForBlock(PageBlock block) {
    if (!_blockControllers.containsKey(block.id)) {
      final ctrl = TextEditingController(text: block.content);
      _blockControllers[block.id] = ctrl;
    } else {
      // If controller text is completely out of sync and not focused, update
      if (_blockControllers[block.id]!.text != block.content &&
          !FocusScope.of(context).hasFocus) {
        _blockControllers[block.id]!.text = block.content;
      }
    }
    return _blockControllers[block.id]!;
  }

  LinearGradient _getCoverGradient(String? name) {
    switch (name) {
      case 'cyan_indigo':
        return const LinearGradient(
          colors: [Color(0xFF0C2340), Color(0xFF1D2A44), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'emerald_teal':
        return const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'amber_rose':
        return const LinearGradient(
          colors: [Color(0xFF451A03), Color(0xFF78350F), Color(0xFF831843)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'violet_dusk':
        return const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF3B0764), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'obsidian':
      default:
        return const LinearGradient(
          colors: [Color(0xFF181B23), Color(0xFF0F1117), Color(0xFF1E222D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _resolveIcon(String iconKey) {
    return _availableIcons[iconKey] ?? Icons.article_outlined;
  }

  void _showSlashMenu(BuildContext context, int atIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceTier1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.cyan),
                    const SizedBox(width: 8),
                    Text('INSERT BLOCK', style: AppTypography.monoBadge.copyWith(color: AppColors.cyan)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.notes_rounded,
                        title: 'Text / Paragraph',
                        subtitle: 'Plain writing block',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.paragraph,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.title_rounded,
                        title: 'Heading 1',
                        subtitle: 'Large section heading',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.heading1,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.format_size_rounded,
                        title: 'Heading 2',
                        subtitle: 'Medium section heading',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.heading2,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.check_box_outlined,
                        title: 'To-do Item',
                        subtitle: 'Interactive checklist task',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.todoItem,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.code_rounded,
                        title: 'Code Snippet',
                        subtitle: 'Monospace code container',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.codeBlock,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.info_outline_rounded,
                        title: 'Callout Note',
                        subtitle: 'Highlighted context card',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.callout,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.arrow_right_rounded,
                        title: 'Toggle List',
                        subtitle: 'Collapsible accordion block',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.toggle,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.horizontal_rule_rounded,
                        title: 'Divider',
                        subtitle: 'Subtle visual separator',
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(workspaceProvider.notifier).addBlock(
                                widget.pageId,
                                PageBlockType.divider,
                                atIndex: atIndex + 1,
                              );
                        },
                      ),
                      _buildBlockTypeTile(
                        ctx,
                        icon: Icons.post_add_rounded,
                        title: 'Subpage',
                        subtitle: 'Nest a new document inside this page',
                        onTap: () async {
                          Navigator.pop(ctx);
                          final subpage = await ref.read(workspaceProvider.notifier).createPage(
                                parentId: widget.pageId,
                                title: 'Untitled Subpage',
                              );
                          if (context.mounted) {
                            context.go('/pages/${subpage.id}');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockTypeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 18, color: AppColors.cyan),
      ),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }

  void _showIconPicker(BuildContext context, WorkspacePage page) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceTier1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Text(
            'Select Document Icon',
            style: AppTypography.heading2.copyWith(fontSize: 16),
          ),
          content: SizedBox(
            width: 320,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.entries.map((entry) {
                final isSelected = page.icon == entry.key;
                return InkWell(
                  onTap: () {
                    ref.read(workspaceProvider.notifier).updatePageIcon(page.id, entry.key);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cyanBg : AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      size: 24,
                      color: isSelected ? AppColors.cyan : AppColors.textHigh,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showCoverPicker(BuildContext context, WorkspacePage page) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceTier1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Text(
            'Choose Cover Gradient',
            style: AppTypography.heading2.copyWith(fontSize: 16),
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._coverOptions.map((cov) {
                  final isSelected = page.coverGradient == cov;
                  return InkWell(
                    onTap: () {
                      ref.read(workspaceProvider.notifier).updatePageCover(page.id, cov);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: _getCoverGradient(cov),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        cov.replaceAll('_', ' ').toUpperCase(),
                        style: AppTypography.monoBadge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  );
                }),
                if (page.coverGradient != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(workspaceProvider.notifier).updatePageCover(page.id, null);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rose),
                    label: Text(
                      'Remove Cover',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.rose, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(workspaceProvider);
    final page = pages.where((p) => p.id == widget.pageId).firstOrNull;

    if (page == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.find_in_page_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Document Not Found',
                style: AppTypography.heading1.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'This page may have been deleted or moved.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF0B0D13)),
                label: Text(
                  'RETURN TO DASHBOARD',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_titleController.text != page.title && !_titleController.selection.isValid) {
      _titleController.text = page.title;
    }

    final children = ref.read(workspaceProvider.notifier).getChildren(page.id);
    final parent = page.parentId != null
        ? ref.read(workspaceProvider.notifier).getPage(page.parentId!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          // Top Breadcrumb & Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTier1,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/dashboard'),
                  child: Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Workspace', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (parent != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textSubtle),
                  ),
                  InkWell(
                    onTap: () => context.go('/pages/${parent.id}'),
                    child: Text(
                      parent.title,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textSubtle),
                ),
                Expanded(
                  child: Text(
                    page.title.isEmpty ? 'Untitled Document' : page.title,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHigh,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    page.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    size: 16,
                    color: page.isPinned ? AppColors.cyan : AppColors.textMuted,
                  ),
                  tooltip: page.isPinned ? 'Unpin Document' : 'Pin Document',
                  onPressed: () {
                    ref.read(workspaceProvider.notifier).togglePin(page.id);
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textMuted),
                  tooltip: 'Document Options',
                  color: AppColors.surfaceTier2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  onSelected: (value) async {
                    if (value == 'cover') {
                      _showCoverPicker(context, page);
                    } else if (value == 'icon') {
                      _showIconPicker(context, page);
                    } else if (value == 'subpage') {
                      final sub = await ref.read(workspaceProvider.notifier).createPage(
                            parentId: page.id,
                            title: 'Untitled Subpage',
                          );
                      if (context.mounted) {
                        context.go('/pages/${sub.id}');
                      }
                    } else if (value == 'delete') {
                      await ref.read(workspaceProvider.notifier).deletePage(page.id);
                      if (context.mounted) {
                        context.go('/dashboard');
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'cover',
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined, size: 16, color: AppColors.cyan),
                          const SizedBox(width: 8),
                          Text(page.coverGradient == null ? 'Add Cover' : 'Change Cover',
                              style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'icon',
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_emotions_outlined, size: 16, color: AppColors.amber),
                          const SizedBox(width: 8),
                          Text('Change Icon', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'subpage',
                      child: Row(
                        children: [
                          const Icon(Icons.post_add_rounded, size: 16, color: AppColors.mint),
                          const SizedBox(width: 8),
                          Text('Add Subpage', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rose),
                          const SizedBox(width: 8),
                          Text('Delete Document',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.rose)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Page Content Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional Cover Banner
                  if (page.coverGradient != null)
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _getCoverGradient(page.coverGradient),
                            border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 12,
                          child: InkWell(
                            onTap: () => _showCoverPicker(context, page),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.palette_outlined, size: 14, color: AppColors.textHigh),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Change Cover',
                                    style: AppTypography.monoBadge.copyWith(
                                      color: AppColors.textHigh,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Document Header: Icon, Hover actions, Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon button
                        InkWell(
                          onTap: () => _showIconPicker(context, page),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTier2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Icon(
                              _resolveIcon(page.icon),
                              size: 28,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Editable Title Field
                        TextField(
                          controller: _titleController,
                          style: AppTypography.heading1.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.textHigh,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Untitled Document',
                            hintStyle: AppTypography.heading1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSubtle,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            ref.read(workspaceProvider.notifier).updatePageTitle(page.id, val);
                          },
                        ),
                        const SizedBox(height: 8),

                        // Document metadata (Updated time & Block count)
                        Row(
                          children: [
                            Text(
                              'Updated ${_formatDate(page.updatedAt)}',
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${page.blocks.length} blocks',
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        const SizedBox(height: 16),

                        // Subpages Quick Tray (if any)
                        if (children.isNotEmpty) ...[
                          Text(
                            'SUBPAGES',
                            style: AppTypography.monoBadge.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: children.map((sub) {
                              return InkWell(
                                onTap: () => context.go('/pages/${sub.id}'),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceTier1,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_resolveIcon(sub.icon), size: 16, color: AppColors.cyan),
                                      const SizedBox(width: 8),
                                      Text(
                                        sub.title.isEmpty ? 'Untitled' : sub.title,
                                        style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded,
                                          size: 10, color: AppColors.textSubtle),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Notion Canvas Blocks
                        ...page.blocks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final block = entry.value;
                          return _buildBlockRow(context, page, block, index);
                        }),

                        const SizedBox(height: 20),

                        // Bottom Canvas Add Block Trigger
                        InkWell(
                          onTap: () => _showSlashMenu(context, page.blocks.length - 1),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTier1,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, size: 16, color: AppColors.cyan),
                                const SizedBox(width: 8),
                                Text(
                                  'Add block or type "/" for commands',
                                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockRow(
    BuildContext context,
    WorkspacePage page,
    PageBlock block,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hover / Tap Action handle to delete or open slash menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.drag_indicator_rounded, size: 16, color: AppColors.textSubtle),
            tooltip: 'Block Actions',
            color: AppColors.surfaceTier2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            onSelected: (action) {
              if (action == 'insert') {
                _showSlashMenu(context, index);
              } else if (action == 'delete') {
                ref.read(workspaceProvider.notifier).deleteBlock(page.id, block.id);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'insert',
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: AppColors.cyan),
                    const SizedBox(width: 8),
                    Text('Insert Block Below', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rose),
                    const SizedBox(width: 8),
                    Text('Delete Block',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.rose)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),

          // Dynamic Block Rendering
          Expanded(
            child: _buildBlockContent(context, page, block, index),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockContent(
    BuildContext context,
    WorkspacePage page,
    PageBlock block,
    int index,
  ) {
    final controller = _getControllerForBlock(block);

    switch (block.type) {
      case PageBlockType.heading1:
        return TextField(
          controller: controller,
          style: AppTypography.heading1.copyWith(
            fontSize: 22,
            color: AppColors.textHigh,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            hintText: 'Heading 1',
            hintStyle: TextStyle(color: AppColors.textSubtle),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          onChanged: (val) {
            if (val.contains('/')) {
              _showSlashMenu(context, index);
              return;
            }
            ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
          },
        );

      case PageBlockType.heading2:
        return TextField(
          controller: controller,
          style: AppTypography.heading2.copyWith(
            fontSize: 18,
            color: AppColors.textHigh,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: 'Heading 2',
            hintStyle: TextStyle(color: AppColors.textSubtle),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          onChanged: (val) {
            if (val.contains('/')) {
              _showSlashMenu(context, index);
              return;
            }
            ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
          },
        );

      case PageBlockType.todoItem:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                ref.read(workspaceProvider.notifier).toggleBlockCheck(page.id, block.id);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 2, right: 8),
                decoration: BoxDecoration(
                  color: block.isChecked ? AppColors.mintBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: block.isChecked ? AppColors.mint : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: block.isChecked
                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.mint)
                    : null,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  decoration: block.isChecked ? TextDecoration.lineThrough : null,
                  color: block.isChecked ? AppColors.textMuted : AppColors.textHigh,
                ),
                decoration: const InputDecoration(
                  hintText: 'To-do item...',
                  hintStyle: TextStyle(color: AppColors.textSubtle),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
                onChanged: (val) {
                  if (val.contains('/')) {
                    _showSlashMenu(context, index);
                    return;
                  }
                  ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
                },
              ),
            ),
          ],
        );

      case PageBlockType.codeBlock:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CODE',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 9),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                    tooltip: 'Copy Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: controller.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                maxLines: null,
                style: AppTypography.monoBadge.copyWith(
                  fontSize: 13,
                  color: AppColors.textHigh,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  hintText: '// Paste or write code here...',
                  hintStyle: TextStyle(color: AppColors.textSubtle, fontFamily: 'monospace'),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
                },
              ),
            ],
          ),
        );

      case PageBlockType.callout:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  style: AppTypography.bodyMedium.copyWith(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Callout note or key takeaway...',
                    hintStyle: TextStyle(color: AppColors.textSubtle),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
                  },
                ),
              ),
            ],
          ),
        );

      case PageBlockType.toggle:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    ref.read(workspaceProvider.notifier).toggleBlockExpanded(page.id, block.id);
                  },
                  child: Icon(
                    block.isExpanded ? Icons.arrow_drop_down_rounded : Icons.arrow_right_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Toggle heading...',
                      hintStyle: TextStyle(color: AppColors.textSubtle),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    onChanged: (val) {
                      ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
                    },
                  ),
                ),
              ],
            ),
            if (block.isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 4),
                child: Text(
                  'Toggle content area. Press / to insert blocks.',
                  style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                ),
              ),
          ],
        );

      case PageBlockType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: AppColors.borderSubtle, height: 1),
        );

      case PageBlockType.paragraph:
        return TextField(
          controller: controller,
          maxLines: null,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 14.5,
            height: 1.55,
            color: AppColors.textHigh,
          ),
          decoration: const InputDecoration(
            hintText: 'Type text or "/" for commands...',
            hintStyle: TextStyle(color: AppColors.textSubtle),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          onChanged: (val) {
            if (val == '/') {
              _showSlashMenu(context, index);
              return;
            }
            ref.read(workspaceProvider.notifier).updateBlockContent(page.id, block.id, val);
          },
        );
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
