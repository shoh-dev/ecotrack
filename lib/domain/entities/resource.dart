// Represents a sustainable living resource (e.g., article, tip, link, video).
// This is a core domain entity.
class Resource {
  final String id; // Unique identifier for the resource
  final String
  title; // Title of the resource (e.g., 'How to Reduce Food Waste')
  final String description; // Short description or summary
  final String type; // e.g., 'Article', 'Tip', 'Video', 'Link'
  final String url; // URL to the resource (if applicable)
  final String?
  category; // Optional category (e.g., 'Home Energy', 'Diet', 'Transportation')
  final String? imageUrl; // Optional URL for a thumbnail image
  final DateTime? publicationDate; // Optional publication date

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url = '', // Default to empty string if no URL
    this.category,
    this.imageUrl,
    this.publicationDate,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'Resource(id: $id, title: $title, type: $type, url: $url)';
  }
}
