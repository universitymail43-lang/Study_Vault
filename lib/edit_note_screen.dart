import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note['title']);
    _contentController = TextEditingController(text: widget.note['content']);
  }

  Future<void> _updateNote() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('notes')
          .update({
            'title': _titleController.text,
            'content': _contentController.text,
          })
          .eq('id', widget.note['id']);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating note: $e")));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteNote() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', widget.note['id']);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting note: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8EE),
      appBar: AppBar(
        title: Text("Edit Note ✏️", style: TextStyle(color: Color(0xFF4A4A4A))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4A4A4A)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Note logic note: editing category not implemented to keep it "easy",
            // as it would require passing categories list or fetching it again here.
            // Focusing on Title/Content as primary edit needs.
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: "Start typing your notes here...",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Color(0xFF4A4A4A)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _deleteNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFB7B2), // Soft red
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "DELETE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD8B9FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
