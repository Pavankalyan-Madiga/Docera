import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.98,
  );

  int _currentPage = 0;

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'ChatWithDocAI',
      'description':
          'Chat with your documents, get summaries, and find answers instantly.',
      'button': 'Try Now',
      'type': 'ai',
    },
    {
      'title': 'PDF Tools',
      'description':
          'Merge, split, compress, convert and protect your PDF files.',
      'button': 'Explore',
      'type': 'pdf',
    },
    {
      'title': 'Image Tools',
      'description':
          'Resize, compress, convert, crop and manage your images easily.',
      'button': 'Explore',
      'type': 'image',
    },
    {
      'title': 'Scan & Make PDF',
      'description':
          'Scan your documents and turn them into high-quality PDFs.',
      'button': 'Scan Now',
      'type': 'scan',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _cards.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCard(_cards[index]),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _cards.length,
            (index) {
              final selected = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 11 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFB9BECC),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    final String type = card['type'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _gradient(type),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _decorations(),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 17, 12, 14),
            child: Row(
              children: [
                Expanded(
                  flex: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _topIcon(type),

                      const SizedBox(height: 9),

                      Text(
                        card['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF11182F),
                          letterSpacing: -0.4,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        card['description'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF69718B),
                        ),
                      ),

                      const Spacer(),

                      _button(
                        card['button'],
                        type,
                      ),

                      if (type == 'ai') ...[
                        const SizedBox(height: 7),
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Color(0xFF5120C8),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '100% Private. Works Offline.',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333A54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  flex: 42,
                  child: _illustration(type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _gradient(String type) {
    switch (type) {
      case 'pdf':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3F2),
            Color(0xFFF4EFFF),
          ],
        );

      case 'image':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFFFF9),
            Color(0xFFE9F4FF),
          ],
        );

      case 'scan':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF7E9),
            Color(0xFFEAF3FF),
          ],
        );

      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F2FF),
            Color(0xFFEDEAFF),
          ],
        );
    }
  }

  Widget _decorations() {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: 50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topIcon(String type) {
    IconData icon;

    switch (type) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        break;
      case 'image':
        icon = Icons.image_rounded;
        break;
      case 'scan':
        icon = Icons.document_scanner_rounded;
        break;
      default:
        icon = Icons.auto_awesome;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        icon,
        size: 18,
        color: type == 'ai'
            ? const Color(0xFF6724D9)
            : const Color(0xFF3F56B5),
      ),
    );
  }

  Widget _button(String title, String type) {
    return Material(
      color: type == 'ai'
          ? const Color(0xFF5120C8)
          : const Color(0xFF2867D9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _illustration(String type) {
    switch (type) {
      case 'pdf':
        return _pdfIllustration();

      case 'image':
        return _imageIllustration();

      case 'scan':
        return _scanIllustration();

      default:
        return _aiIllustration();
    }
  }

  Widget _aiIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF9B7BFF).withValues(alpha: 0.2),
          ),
        ),

        Positioned(
          top: 20,
          right: 0,
          child: Container(
            width: 48,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 4, color: Color(0xFF5A7DEB)),
                SizedBox(width: 4),
                Icon(Icons.circle, size: 4, color: Color(0xFF5A7DEB)),
                SizedBox(width: 4),
                Icon(Icons.circle, size: 4, color: Color(0xFF5A7DEB)),
              ],
            ),
          ),
        ),

        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF273A82),
                Color(0xFF101B50),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            size: 42,
            color: Color(0xFF5BE8F5),
          ),
        ),
      ],
    );
  }

  Widget _pdfIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF9E7CF5).withValues(alpha: 0.15),
          ),
        ),
        Transform.rotate(
          angle: -0.12,
          child: Container(
            width: 72,
            height: 98,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  height: 27,
                  width: 27,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D54),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(height: 7),
                ...List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    height: 4,
                    width: index == 3 ? 28 : 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE0EC),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5CD6B1).withValues(alpha: 0.15),
          ),
        ),
        Container(
          width: 95,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.image_rounded,
            size: 45,
            color: Color(0xFF34C99A),
          ),
        ),
      ],
    );
  }

  Widget _scanIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6F9EFF).withValues(alpha: 0.14),
          ),
        ),
        Container(
          width: 67,
          height: 105,
          decoration: BoxDecoration(
            color: const Color(0xFF202B45),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F8),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(
              child: Icon(
                Icons.document_scanner_rounded,
                size: 36,
                color: Color(0xFF4E78E8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}