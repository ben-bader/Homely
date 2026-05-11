/// Pagination response wrapper
class PaginatedResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool isFirst;
  final bool isLast;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse(
      content: List<T>.from(
        (json['content'] as List<dynamic>).map((item) => fromJsonT(item)),
      ),
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      isFirst: json['isFirst'] as bool,
      isLast: json['isLast'] as bool,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }

  bool get canLoadMore => hasNext;
  int get nextPageNumber => pageNumber + 1;
}
