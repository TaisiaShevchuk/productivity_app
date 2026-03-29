class NoteItem {
  final String text;
  final bool isCheckbox;
  final bool isChecked;

  NoteItem({
    required this.text,
    this.isCheckbox = false,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCheckbox': isCheckbox ? 1 : 0,
      'isChecked': isChecked ? 1 : 0,
    };
  }

  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      text: map['text'],
      isCheckbox: map['isCheckbox'] == 1,
      isChecked: map['isChecked'] == 1,
    );
  }
}
