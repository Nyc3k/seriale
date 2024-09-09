class ApiResponse {
  final String title;
  final String type;
  final String year;
  final int id;

  ApiResponse({required this.title, required this.type, required this.year, required this.id});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      title: json['name'],
      type: json['result_type'],
      year: json['year'].toString(),
      id: json['id'],
    );
  }
}
