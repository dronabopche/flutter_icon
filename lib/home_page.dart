import 'dart:ui';
import 'package:flutter/material.dart';
import 'pages/exploration_popup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_item.dart';
import 'pages/details_page.dart';
import 'pages/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ContentItem> _items = [];
  List<ContentItem> _displayedItems = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _showContactArea = false;
  bool _showIntroText = true;

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 30;
  bool _hasMoreItems = true;

  // Hover states for social icons
  final Map<String, bool> _hoverStates = {
    'instagram': false,
    'facebook': false,
    'github': false,
    'twitter': false,
  };

  Future<void> _fetchItems({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _hasMoreItems = true;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      // Calculate range for pagination
      final from = (loadMore ? _currentPage * _itemsPerPage : 0);
      final to = from + _itemsPerPage - 1;

      final response = await Supabase.instance.client
          .from('content_items')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      List<ContentItem> newItems = (response as List)
          .map((data) => ContentItem.fromJson(data))
          .toList();

      // Check if we have more items to load
      if (newItems.length < _itemsPerPage) {
        _hasMoreItems = false;
      }

      setState(() {
        if (loadMore) {
          _displayedItems.addAll(newItems);
          _currentPage++;
        } else {
          _items = newItems;
          _displayedItems = List.from(newItems);
          _currentPage = 1;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      print('Error fetching items: $error');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadMoreItems() {
    if (!_isLoadingMore && _hasMoreItems) {
      _fetchItems(loadMore: true);
    }
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }

    // Show contact area only when scrolled to bottom and all items loaded
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_hasMoreItems &&
        _displayedItems.isNotEmpty) {
      if (!_showContactArea) {
        setState(() {
          _showContactArea = true;
        });
      }
    }

    // Hide intro text when scrolling down
    if (_scrollController.position.pixels > 100 && _showIntroText) {
      setState(() {
        _showIntroText = false;
      });
    } else if (_scrollController.position.pixels <= 100 && !_showIntroText) {
      setState(() {
        _showIntroText = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchItems();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        leading: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.animation,
                color: Color(0xFFFFFFFF),
                size: isTablet ? 24 : 30,
              ),
              SizedBox(width: isMobile ? 2 : 4),
              Visibility(
                visible: !isMobile,
                child: Text(
                  'FLUTTER ICON',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                    color: Color(0xFFFFFFFF),
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                        color: const Color.fromARGB(255, 49, 49, 49),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        leadingWidth: isMobile ? 120 : 200,
        title: Text(
          isMobile
              ? ' ICON Animations Library'
              : 'Flutter ICON Animations Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: isMobile ? 16 : 20,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 7,
                color: Color.fromARGB(255, 75, 75, 75),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SearchPage(),
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
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: _buildGlassDrawer(),
      body: Stack(
        children: [
          // Responsive Background Image
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
          _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Animations...',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      // Introductory Text with Glass Effect - Animated
                      AnimatedOpacity(
                        opacity: _showIntroText ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _showIntroText ? null : 0,
                          margin: EdgeInsets.only(
                            bottom: _showIntroText ? (isMobile ? 12 : 16) : 0,
                          ),
                          child: _buildIntroductoryText(isMobile),
                        ),
                      ),

                      // Item count indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMobile ? 8 : 12,
                        ),
                        margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_displayedItems.length} Animations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_hasMoreItems)
                              Text(
                                'Page $_currentPage',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: isMobile ? 11 : 13,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Grid View
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              final metrics = scrollNotification.metrics;
                              if (metrics.pixels >=
                                      metrics.maxScrollExtent - 50 &&
                                  !_hasMoreItems &&
                                  _displayedItems.isNotEmpty) {
                                if (!_showContactArea) {
                                  setState(() {
                                    _showContactArea = true;
                                  });
                                }
                              }
                            }
                            return false;
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive grid configuration
                              int crossAxisCount;
                              double childAspectRatio;
                              double crossAxisSpacing;
                              double mainAxisSpacing;

                              if (screenWidth < 600) {
                                // Mobile
                                crossAxisCount = 2;
                                childAspectRatio = 0.8;
                                crossAxisSpacing = 8.0;
                                mainAxisSpacing = 8.0;
                              } else if (screenWidth < 900) {
                                // Small tablet
                                crossAxisCount = 3;
                                childAspectRatio = 0.85;
                                crossAxisSpacing = 12.0;
                                mainAxisSpacing = 12.0;
                              } else if (screenWidth < 1200) {
                                // Tablet
                                crossAxisCount = 4;
                                childAspectRatio = 0.9;
                                crossAxisSpacing = 16.0;
                                mainAxisSpacing = 16.0;
                              } else if (screenWidth < 1800) {
                                // Desktop
                                crossAxisCount = 5;
                                childAspectRatio = 0.9;
                                crossAxisSpacing = 16.0;
                                mainAxisSpacing = 16.0;
                              } else {
                                // Large desktop
                                crossAxisCount = 6;
                                childAspectRatio = 0.9;
                                crossAxisSpacing = 16.0;
                                mainAxisSpacing = 16.0;
                              }

                              return GridView.builder(
                                controller: _scrollController,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: crossAxisSpacing,
                                      mainAxisSpacing: mainAxisSpacing,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                itemCount:
                                    _displayedItems.length +
                                    (_hasMoreItems ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _displayedItems.length) {
                                    // Loading indicator at the end
                                    return _buildLoadingCard(isMobile);
                                  }
                                  final item = _displayedItems[index];
                                  return _buildGifCard(item, context, isMobile);
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // Contact Area (only shown when scrolled to bottom and all items loaded)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        height: _showContactArea ? (isMobile ? 80 : 100) : 0,
                        margin: EdgeInsets.only(
                          top: _showContactArea ? (isMobile ? 8 : 12) : 0,
                        ),
                        child: _showContactArea
                            ? _buildContactArea(isMobile)
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildIntroductoryText(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '🚀 Looking for Cool Animations?',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                'Explore ${_displayedItems.length}+ stunning Flutter animations!',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactArea(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    platform: 'instagram',
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    url: 'https://instagram.com/yourusername',
                    isMobile: isMobile,
                  ),
                  _buildSocialButton(
                    platform: 'facebook',
                    icon: Icons.facebook,
                    label: 'Facebook',
                    url: 'https://facebook.com/yourusername',
                    isMobile: isMobile,
                  ),
                  _buildSocialButton(
                    platform: 'github',
                    icon: Icons.code,
                    label: 'GitHub',
                    url: 'https://github.com/yourusername',
                    isMobile: isMobile,
                  ),
                  _buildSocialButton(
                    platform: 'twitter',
                    icon: Icons.chat,
                    label: 'Twitter',
                    url: 'https://twitter.com/yourusername',
                    isMobile: isMobile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String platform,
    required IconData icon,
    required String label,
    required String url,
    required bool isMobile,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverStates[platform] = true),
      onExit: (_) => setState(() => _hoverStates[platform] = false),
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hoverStates[platform]!
                  ? [
                      Color(0xFFE1306C).withOpacity(0.3),
                      Color(0xFF405DE6).withOpacity(0.3),
                    ]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
            ),
            boxShadow: _hoverStates[platform]!
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: isMobile ? 14 : 16),
              SizedBox(width: isMobile ? 4 : 6),
              AnimatedCrossFade(
                duration: Duration(milliseconds: 200),
                crossFadeState: _hoverStates[platform]!
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Container(width: 0, height: 0),
                secondChild: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isMobile) {
    return ClipRRect(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
              SizedBox(height: 8),
              Text(
                'Loading more...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDrawer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            width: isMobile ? screenWidth * 0.8 : screenWidth * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 53, 53, 53).withOpacity(0.1),
                  const Color.fromARGB(255, 65, 65, 65).withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drawer Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.animation,
                          size: isMobile ? 32 : 40,
                          color: Colors.white,
                        ),
                        SizedBox(height: isMobile ? 8 : 10),
                        Text(
                          'Flutter Animations',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          'Library',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drawer Items
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      children: [
                        _buildDrawerItem(
                          icon: Icons.home,
                          title: 'Home',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                        _buildDrawerItem(
                          icon: Icons.coffee,
                          title: 'BUY ME A COFFEE',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExplorationPopup(),
                              ),
                            );
                          },
                          isMobile: isMobile,
                        ),
                        _buildDrawerItem(
                          icon: Icons.favorite,
                          title: 'Favorites',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                        _buildDrawerItem(
                          icon: Icons.download,
                          title: 'Downloaded',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        Divider(color: Colors.white30),
                        SizedBox(height: isMobile ? 8 : 10),
                        _buildDrawerItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                        _buildDrawerItem(
                          icon: Icons.help,
                          title: 'Help & Support',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                        _buildDrawerItem(
                          icon: Icons.info,
                          title: 'About',
                          onTap: () {
                            Navigator.pop(context);
                          },
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: isMobile ? 10 : 12,
                          ),
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        Text(
                          '© 2024 Flutter Animations',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: isMobile ? 9 : 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return ListTile(
      hoverColor: const Color.fromARGB(255, 255, 148, 203).withOpacity(0.1),
      focusColor: Colors.white.withOpacity(0.15),
      selectedTileColor: Colors.white.withOpacity(0.2),
      leading: Icon(
        icon,
        color: Colors.white.withOpacity(0.8),
        size: isMobile ? 20 : 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: isMobile ? 13 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      minLeadingWidth: isMobile ? 25 : 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildGifCard(ContentItem item, BuildContext context, bool isMobile) {
    return ClipRRect(
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
                MaterialPageRoute(builder: (context) => DetailPage(item: item)),
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
                  child: ClipRect(
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
    );
  }
}
