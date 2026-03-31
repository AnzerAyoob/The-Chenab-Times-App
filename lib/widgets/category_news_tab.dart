import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:the_chenab_times/utils/app_status_handler.dart';
import '../models/article_model.dart';
import '../services/language_service.dart';
import '../services/rss_service.dart';
import '../screens/article_screen.dart';
import '../utils/html_helper.dart';

class CategoryNewsTab extends StatefulWidget {
  final int categoryId;
  const CategoryNewsTab({super.key, required this.categoryId});

  @override
  State<CategoryNewsTab> createState() => _CategoryNewsTabState();
}

class _CategoryNewsTabState extends State<CategoryNewsTab> with AutomaticKeepAliveClientMixin {
  final RssService _rss = RssService();
  final List<Article> _items = [];
  int _page = 1;
  bool _loading = true;
  bool _hasMore = true;
  bool _hasError = false;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  late LanguageService _languageService;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300 &&
          !_loading &&
          _hasMore &&
          !_hasError) {
        _fetchPage();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageService = Provider.of<LanguageService>(context);
    _languageService.addListener(_onLanguageChange);
    _fetchPage(isInitial: true);
  }

  void _onLanguageChange() {
    _refresh();
  }

  Future<void> _fetchPage({bool isInitial = false}) async {
    if (mounted) setState(() => _loading = true);
    try {
      final pageItems = await _rss.fetchCategoryPosts(
          categoryId: widget.categoryId,
          page: _page,
          perPage: 15,
          languageCode: _languageService.appLocale.languageCode);
      if (pageItems.isEmpty) {
        if (mounted) setState(() => _hasMore = false);
      } else {
        if (mounted) {
          setState(() {
            if (isInitial) _items.clear();
            _items.addAll(pageItems);
            _page++;
            _hasError = false; // Reset error on success
          });
          if (_page == 2) {
            AppStatusHandler.showStatusToast(
                message: "Category feed loaded successfully.",
                type: StatusType.success);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        if (_items.isEmpty) {
          setState(() {
            _hasError = true;
            _errorMessage =
                'Could not connect to the server. Please check your internet connection.';
          });
          AppStatusHandler.showStatusToast(
              message: _errorMessage, type: StatusType.error);
        } else {
          AppStatusHandler.showStatusToast(
              message: 'Could not load more articles. Pull down to retry.',
              type: StatusType.warning);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _hasError = false;
      _items.clear();
      _page = 1;
      _hasMore = true;
      _loading = true;
    });
    await _fetchPage();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError && _items.isEmpty) {
      // Full screen error for initial load failure
      return RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200, // Approximate available height
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/loading.json', width: 150, height: 150),
                  const SizedBox(height: 16),
                  Text(_errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Pull down to refresh',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: (_loading && _items.isEmpty)
          ? _buildSkeletonLoader()
          : ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, idx) {
                if (idx >= _items.length) {
                  return _hasMore
                      ? Center(
                          child: Lottie.asset(
                            'assets/loading.json',
                            width: 150,
                            height: 150,
                          ),
                        )
                      : const SizedBox.shrink();
                }
                final a = _items[idx];
                final imageUrl = a.thumbnailUrl ?? a.imageUrl;
                return ListTile(
                  leading: SizedBox(
                    width: 80,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : Container(
                            width: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported)),
                  ),
                  title: Text(HtmlHelper.stripAndUnescape(a.title ?? ''),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(HtmlHelper.stripAndUnescape(a.excerpt ?? ''),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text(a.author ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis)),
                          if (a.date != null)
                            Text(DateFormat.yMMMd().format(a.date!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ArticleScreen(articles: _items, initialIndex: idx))),
                );
              },
            ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Center(
      child: Lottie.asset(
        'assets/loading.json',
        width: 150,
        height: 150,
      ),
    );
  }
}
