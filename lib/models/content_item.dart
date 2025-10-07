class ContentItem {
  final String id;
  final String title;
  final String gifUrl;
  final String codeSnippet;
  final String description;
  final String dependencies; // New field

  ContentItem({
    required this.id,
    required this.title,
    required this.gifUrl,
    required this.codeSnippet,
    required this.description,
    required this.dependencies, // Added to constructor
  });

  // A helper method to create a ContentItem from JSON data Supabase returns
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      title: json['title'],
      gifUrl: json['gif_url'],
      codeSnippet: json['code_snippet'],
      description: json['description'],
      dependencies: json['dependencies'] ?? '', // Handle null case
    );
  }
}
