import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/summarization_service.dart';
import '../utils/html_helper.dart';

class ArticleScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;

  const ArticleScreen({
    super.key,
    required this.articles,
    required this.initialIndex,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late int index;
  String? summary;
  bool loading = true;

  Article get article => widget.articles[index];

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    loadSummary();
  }

  Future<void> loadSummary() async {
    final result =
        await SummarizationService.instance.summarizeArticle(
      article.content ?? '',
      articleLink: article.link,
      excerpt: article.excerpt,
    );

    if (!mounted) return;

    setState(() {
      summary = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5efe6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [

                    Image.network(
                      article.image ?? '',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: const Text(
                        "Quick summary crafted for fast reading",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// SUMMARY CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      color: Colors.black.withOpacity(.05),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITLE CHIP
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xff8d1b1b),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "READ IN SHORT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LOADER
                    if (loading)
                      Column(
                        children: const [
                          SizedBox(height: 20),
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            "Preparing your short summary...",
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      )

                    /// SUMMARY TEXT
                    else if (summary != null)
                      Text(
                        HtmlHelper.stripAndUnescape(summary!),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      )

                    /// FINAL FALLBACK
                    else
                      const Text(
                        "Summary not available at the moment.",
                        style: TextStyle(fontSize: 15),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FULL ARTICLE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8d1b1b),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Read Full Article",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
