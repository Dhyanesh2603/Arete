import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommandPaletteState {
  final bool isOpen;
  final String query;
  final int selectedIndex;

  const CommandPaletteState({
    this.isOpen = false,
    this.query = '',
    this.selectedIndex = 0,
  });

  CommandPaletteState copyWith({
    bool? isOpen,
    String? query,
    int? selectedIndex,
  }) {
    return CommandPaletteState(
      isOpen: isOpen ?? this.isOpen,
      query: query ?? this.query,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CommandPaletteNotifier extends StateNotifier<CommandPaletteState> {
  CommandPaletteNotifier() : super(const CommandPaletteState());

  void open() => state = state.copyWith(isOpen: true, query: '', selectedIndex: 0);
  void close() => state = state.copyWith(isOpen: false);
  void toggle() => state = state.copyWith(isOpen: !state.isOpen, query: '', selectedIndex: 0);

  void setQuery(String query) {
    state = state.copyWith(query: query, selectedIndex: 0);
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

final commandPaletteProvider =
    StateNotifierProvider<CommandPaletteNotifier, CommandPaletteState>((ref) {
  return CommandPaletteNotifier();
});
