import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/content_item.dart';
import 'details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ContentItem> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _hasMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 30;
  late FocusNode _searchFocusNode;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(
    String query, {
    int page = 1,
    bool loadMore = false,
  }) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
        _hasMore = false;
        _currentPage = 1;
      });
      return;
    }

    if (!loadMore) {
      setState(() {
        _isSearching = true;
        _hasSearched = true;
        _currentPage = page;
        _currentQuery = query;
      });
    }

    try {
      final from = (page - 1) * _itemsPerPage;
      final to = from + _itemsPerPage - 1;

      final response = await Supabase.instance.client
          .from('content_items')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false)
          .range(from, to);

      List<ContentItem> results = (response as List)
          .map((data) => ContentItem.fromJson(data))
          .toList();

      // Check if there are more results
      final countResponse = await Supabase.instance.client
          .from('content_items')
          .select('count')
          .ilike('title', '%$query%');

      final totalCount = countResponse[0]['count'] as int;
      final hasMoreResults = page * _itemsPerPage < totalCount;

      setState(() {
        if (loadMore) {
          _searchResults.addAll(results);
        } else {
          _searchResults = results;
        }
        _isSearching = false;
        _hasMore = hasMoreResults;
        _currentPage = page;
      });
    } catch (error) {
      print('Error searching items: $error');
      setState(() {
        _isSearching = false;
        if (!loadMore) {
          _searchResults = [];
        }
      });
    }
  }

  void _loadMoreResults() {
    if (_hasMore && !_isSearching) {
      _performSearch(_currentQuery, page: _currentPage + 1, loadMore: true);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (_searchController.text.trim() == query) {
          _performSearch(query);
        }
      });
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
        _hasMore = false;
        _currentPage = 1;
        _currentQuery = '';
      });
    }
  }

  void _goToPage(int page) {
    if (page != _currentPage && !_isSearching) {
      _performSearch(_currentQuery, page: page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: isMobile ? 20 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: isMobile ? 40 : 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
              ],
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) => _onSearchChanged(),
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16),
            decoration: InputDecoration(
              hintText: 'Search animations by title...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isMobile ? 14 : 16,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.7),
                size: isMobile ? 20 : 24,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
            ),
            cursorColor: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Glass effect overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 53, 53, 53).withOpacity(0.3),
                  const Color.fromARGB(255, 65, 65, 65).withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (isMobile ? 80 : 100),
            ),
            child: _buildSearchContent(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContent(bool isMobile) {
    if (_isSearching && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.white.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              'Search animations by title',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Type in the search bar to find specific animations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results count and pagination info
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_searchResults.length} results found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
              if (_hasMore || _currentPage > 1)
                Text(
                  'Page $_currentPage',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
            ],
          ),
        ),

        // Grid view
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.extentAfter == 0 &&
                    _hasMore &&
                    !_isSearching) {
                  _loadMoreResults();
                }
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(
                        MediaQuery.of(context).size.width,
                      ),
                      crossAxisSpacing: _getCrossAxisSpacing(
                        MediaQuery.of(context).size.width,
                      ),
                      mainAxisSpacing: _getMainAxisSpacing(
                        MediaQuery.of(context).size.width,
                      ),
                      childAspectRatio: _getChildAspectRatio(
                        MediaQuery.of(context).size.width,
                      ),
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = _searchResults[index];
                      return _buildSearchResultCard(item, context, isMobile);
                    }, childCount: _searchResults.length),
                  ),

                  // Load more indicator
                  if (_hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: _isSearching
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _loadMoreResults,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  child: Text('Load More Results'),
                                ),
                        ),
                      ),
                    ),

                  // Pagination controls
                  if (_currentPage > 1 || _hasMore)
                    SliverToBoxAdapter(
                      child: _buildPaginationControls(isMobile),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(bool isMobile) {
    final totalPages = _hasMore ? _currentPage + 1 : _currentPage;

    return Container(
      padding: EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                if (_currentPage > 1)
                  IconButton(
                    onPressed: () => _goToPage(_currentPage - 1),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),

                // Page numbers
                SizedBox(width: 8),
                for (int i = 1; i <= totalPages; i++)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      onPressed: () => _goToPage(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: i == _currentPage
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        minimumSize: Size(40, 40),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text('$i'),
                    ),
                  ),
                SizedBox(width: 8),

                // Next button
                if (_hasMore)
                  IconButton(
                    onPressed: () => _goToPage(_currentPage + 1),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1200) return 4;
    return 5;
  }

  double _getCrossAxisSpacing(double screenWidth) {
    if (screenWidth < 600) return 8.0;
    if (screenWidth < 900) return 12.0;
    return 16.0;
  }

  double _getMainAxisSpacing(double screenWidth) {
    if (screenWidth < 600) return 8.0;
    if (screenWidth < 900) return 12.0;
    return 16.0;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 0.8;
    if (screenWidth < 900) return 0.85;
    return 0.9;
  }

  Widget _buildSearchResultCard(
    ContentItem item,
    BuildContext context,
    bool isMobile,
  ) {
    return MouseRegion(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                  ],
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          DetailPage(item: item),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                      transitionDuration: Duration(milliseconds: 400),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // GIF Container
                    Container(
                      height: isMobile ? 120 : 170,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Image.network(
                        item.gifUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200.withOpacity(0.5),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: isMobile ? 30 : 40,
                            ),
                          );
                        },
                      ),
                    ),

                    // Title section
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 6.0 : 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 11 : 12,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isMobile ? 2 : 4),
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 10,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
