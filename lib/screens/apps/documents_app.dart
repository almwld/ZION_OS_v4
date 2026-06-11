import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentsApp extends StatefulWidget {
  const DocumentsApp({super.key});

  @override
  State<DocumentsApp> createState() => _DocumentsAppState();
}

class _DocumentsAppState extends State<DocumentsApp> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategory = 0;
  
  final List<String> _categories = ['All', 'PDF', 'Word', 'Excel', 'PPT', 'TXT', 'Recent'];
  
  final List<Map<String, dynamic>> _documents = [
    {'name': 'Annual Report 2024.pdf', 'size': '2.5 MB', 'date': '2024-12-01', 'type': 'PDF', 'pages': 45},
    {'name': 'Project Proposal.docx', 'size': '1.8 MB', 'date': '2024-11-28', 'type': 'Word', 'pages': 12},
    {'name': 'Budget Summary.xlsx', 'size': '0.9 MB', 'date': '2024-11-25', 'type': 'Excel', 'sheets': 5},
    {'name': 'Presentation.pptx', 'size': '3.2 MB', 'date': '2024-11-20', 'type': 'PPT', 'slides': 24},
    {'name': 'README.txt', 'size': '0.1 MB', 'date': '2024-11-15', 'type': 'TXT', 'lines': 150},
    {'name': 'Contract Agreement.pdf', 'size': '1.2 MB', 'date': '2024-11-10', 'type': 'PDF', 'pages': 8},
    {'name': 'Meeting Notes.docx', 'size': '0.5 MB', 'date': '2024-11-05', 'type': 'Word', 'pages': 3},
    {'name': 'Sales Data.xlsx', 'size': '2.1 MB', 'date': '2024-10-30', 'type': 'Excel', 'sheets': 8},
    {'name': 'Training Material.pptx', 'size': '4.5 MB', 'date': '2024-10-25', 'type': 'PPT', 'slides': 35},
    {'name': 'Notes.txt', 'size': '0.05 MB', 'date': '2024-10-20', 'type': 'TXT', 'lines': 45},
  ];
  
  final List<Map<String, dynamic>> _folders = [
    {'name': 'Work', 'count': 12, 'icon': Icons.work},
    {'name': 'Personal', 'count': 8, 'icon': Icons.person},
    {'name': 'Invoices', 'count': 15, 'icon': Icons.receipt},
    {'name': 'Reports', 'count': 7, 'icon': Icons.assessment},
    {'name': 'Templates', 'count': 5, 'icon': Icons.template},
    {'name': 'Archives', 'count': 9, 'icon': Icons.archive},
  ];

  List<Map<String, dynamic>> get _filteredDocuments {
    var docs = _documents;
    
    if (_selectedCategory > 0 && _selectedCategory < 6) {
      final category = _categories[_selectedCategory];
      docs = docs.where((doc) => doc['type'] == category).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      docs = docs.where((doc) => 
        doc['name'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return docs;
  }

  void _openDocument(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getDocumentIcon(doc['type']), color: const Color(0xFF00BCD4), size: 50),
              const SizedBox(height: 16),
              Text(doc['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Type: ${doc['type']}', style: const TextStyle(color: Colors.white54)),
              Text('Size: ${doc['size']}', style: const TextStyle(color: Colors.white54)),
              Text('Date: ${doc['date']}', style: const TextStyle(color: Colors.white54)),
              if (doc.containsKey('pages'))
                Text('Pages: ${doc['pages']}', style: const TextStyle(color: Colors.white54)),
              if (doc.containsKey('sheets'))
                Text('Sheets: ${doc['sheets']}', style: const TextStyle(color: Colors.white54)),
              if (doc.containsKey('slides'))
                Text('Slides: ${doc['slides']}', style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: doc['name']));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File name copied'), backgroundColor: Color(0xFF00BCD4)),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Name'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'Word': return Icons.description;
      case 'Excel': return Icons.table_chart;
      case 'PPT': return Icons.slideshow;
      case 'TXT': return Icons.text_snippet;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type) {
      case 'PDF': return Colors.red;
      case 'Word': return Colors.blue;
      case 'Excel': return Colors.green;
      case 'PPT': return Colors.orange;
      case 'TXT': return Colors.grey;
      default: return const Color(0xFF00BCD4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = _filteredDocuments;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Documents', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, color: Color(0xFF00BCD4)),
            onPressed: () {},
            tooltip: 'Upload',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF00BCD4)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF00BCD4)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Categories
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFF00BCD4).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : const Color(0xFF00BCD4),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Folders Section
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(folder['icon'], color: const Color(0xFF00BCD4), size: 28),
                      const SizedBox(height: 4),
                      Text(
                        folder['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        '${folder['count']} files',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Documents List
          Expanded(
            child: documents.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('No documents found', style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      final color = _getDocumentColor(doc['type']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getDocumentIcon(doc['type']), color: color, size: 24),
                          ),
                          title: Text(
                            doc['name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${doc['size']} • ${doc['date']}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share, color: Color(0xFF00BCD4), size: 18),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Color(0xFF00BCD4), size: 18),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          onTap: () => _openDocument(doc),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
