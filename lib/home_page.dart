import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_item.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ContentItem> _items = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _fetchItems() async {
    try {
      final response = await Supabase.instance.client
          .from('content_items')
          .select()
          .order('created_at', ascending: false);

      List<ContentItem> items = (response as List)
          .map((data) => ContentItem.fromJson(data))
          .toList();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching items: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
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
              Icon(Icons.animation, size: isMobile ? 24 : 30),
              SizedBox(width: isMobile ? 2 : 4),
              Visibility(
                visible: !isMobile,
                child: Text(
                  'FLUTTER ICON',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black45,
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
          isMobile ? 'Animations Library' : 'Flutter Animations Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: isMobile ? 16 : 20,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
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
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildGifCard(item, context, isMobile);
                        },
                      );
                    },
                  ),
                ),
        ],
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
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
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
                          icon: Icons.explore,
                          title: 'Explore Animations',
                          onTap: () {
                            Navigator.pop(context);
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
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
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
