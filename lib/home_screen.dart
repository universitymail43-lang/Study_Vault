import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Store full objects if needed, but for now simple names for categories
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> notes = [];
  String selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    // Only show loading if verify user or initial load
    // setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        ); // Or Login
        return;
      }

      // Fetch categories with timeout
      final catResponse = await Supabase.instance.client
          .from('categories')
          .select()
          .order('created_at', ascending: true)
          .timeout(Duration(seconds: 10));

      // Fetch notes with timeout
      final notesResponse = await Supabase.instance.client
          .from('notes')
          .select()
          .order('created_at', ascending: false)
          .timeout(Duration(seconds: 10));

      if (mounted) {
        setState(() {
          categories = List<Map<String, dynamic>>.from(catResponse);
          notes = List<Map<String, dynamic>>.from(notesResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e"); // Debug print
      if (mounted) {
        setState(() => _isLoading = false); // Ensure stop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Something went wrong. Pull to refresh or check connection.",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    String newCategory = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Add Category ✨"),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newCategory.isNotEmpty) {
                  Navigator.pop(context); // Close dialog first
                  try {
                    await Supabase.instance.client.from('categories').insert({
                      'user_id': Supabase.instance.client.auth.currentUser!.id,
                      'name': newCategory,
                    });
                    _fetchData(); // Refresh
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add category")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD8B9FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _togglePin(String noteId, bool currentStatus) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_pinned': !currentStatus})
          .eq('id', noteId);
      _fetchData(); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating note: $e")));
    }
  }

  // Filter notes based on selected category
  List<Map<String, dynamic>> get _filteredNotes {
    if (selectedCategory == 'All') {
      return notes;
    }
    if (selectedCategory == 'Important') {
      return notes.where((n) => n['is_pinned'] == true).toList();
    }

    // Easier approach for beginner: filtered list logic
    final selectedCatObj = categories.firstWhere(
      (c) => c['name'] == selectedCategory,
      orElse: () => {},
    );

    if (selectedCatObj.isEmpty) return [];

    return notes
        .where((n) => n['category_id'] == selectedCatObj['id'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Combine 'All', 'Important' with dynamic categories
    final displayCategories = [
      'All',
      'Important',
      ...categories.map((c) => c['name'].toString()).toList(),
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF8E8EE),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFD8B9FF)))
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ${Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? 'Scholar'} 🌸",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                            Text(
                              "Let's learn something new!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFFD8B9FF),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
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
                        decoration: InputDecoration(
                          hintText: "Search notes...",
                          icon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...displayCategories.map((category) {
                            bool isSelected = category == selectedCategory;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFFD8B9FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF4A4A4A),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          GestureDetector(
                            onTap: _showAddCategoryDialog,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFFD8B9FF),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Color(0xFFD8B9FF),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Color(0xFFD8B9FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          final isPinned = note['is_pinned'] == true;

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditNoteScreen(note: note),
                                ),
                              );
                              _fetchData(); // Refresh on return
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A4A4A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _togglePin(note['id'], isPinned),
                                        child: Icon(
                                          isPinned
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 28,
                                          color: isPinned
                                              ? Color(0xFFFFB7B2)
                                              : Colors.grey[300],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    note['content'] == null ||
                                            note['content'].toString().length <
                                                50
                                        ? (note['content'] ?? '')
                                        : "${note['content'].substring(0, 50)}...",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    note['created_at'].toString().substring(
                                      0,
                                      10,
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(categories: categories),
            ),
          );
          _fetchData(); // Refresh on return
        },
        backgroundColor: Color(0xFFD8B9FF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
