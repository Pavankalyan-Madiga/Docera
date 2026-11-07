import 'package:docera/features/tools/models/tool_model.dart';
import 'package:docera/features/tools/presentation/pages/add_page/add_page_page.dart';
import 'package:docera/features/tools/presentation/pages/compress_pdf/compress_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/crop_pdf/crop_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/delete_pages/delete_pages_page.dart';
import 'package:docera/features/tools/presentation/pages/edit_pdf/edit_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/excel_to_pdf/excel_to_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/extract_pages/extract_pages_page.dart';
import 'package:docera/features/tools/presentation/pages/images_to_pdf/images_to_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/merge_pdf/merge_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/number_pages/number_pages_page.dart';
import 'package:docera/features/tools/presentation/pages/ocr/ocr_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_info/pdf_info_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_protect/pdf_protect_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_sign/pdf_sign_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_to_excel/pdf_to_excel_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_to_images/pdf_to_images_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_to_ppt/pdf_to_ppt_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_to_word/pdf_to_word_page.dart';
import 'package:docera/features/tools/presentation/pages/pdf_unlock/pdf_unlock_page.dart';
import 'package:docera/features/tools/presentation/pages/ppt_to_pdf/ppt_to_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/rearrange_pages/rearrange_pages_page.dart';
import 'package:docera/features/tools/presentation/pages/rotate_pages/rotate_pages_page.dart';
import 'package:docera/features/tools/presentation/pages/scan_document/scan_document_page.dart';
import 'package:docera/features/tools/presentation/pages/split_pdf/split_pdf_page.dart';
import 'package:docera/features/tools/presentation/pages/watermark/watermark_page.dart';
import 'package:docera/features/tools/presentation/pages/word_to_pdf/word_to_pdf_page.dart';
import 'package:docera/features/tools/presentation/widgets/tool_section.dart';
import 'package:flutter/material.dart';


class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final popularTools = [
      ToolModel(
        title: 'Scan\nDocument',
        icon: Icons.document_scanner_outlined,
        iconColor: const Color(0xFF8B2CF5),
        backgroundColor: const Color(0xFFF1E5FF),
        onTap: () => _openPage(
          context,
          const ScanDocumentPage(),
        ),
      ),
      ToolModel(
        title: 'OCR\n(Image to Text)',
        icon: Icons.text_fields_rounded,
        iconColor: const Color(0xFF13A66B),
        backgroundColor: const Color(0xFFE4F8F0),
        onTap: () => _openPage(
          context,
          const OcrPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nSign',
        icon: Icons.draw_rounded,
        iconColor: const Color(0xFFFF3048),
        backgroundColor: const Color(0xFFFFE7EA),
        onTap: () => _openPage(
          context,
          const Pdf_SignPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nProtect',
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF146CE8),
        backgroundColor: const Color(0xFFE7F0FF),
        onTap: () => _openPage(
          context,
          const PdfProtectPage(),
        ),
      ),
    ];

    final convertToPdfTools = [
      ToolModel(
        title: 'Word\nto PDF',
        icon: Icons.description_rounded,
        iconColor: const Color(0xFF1478E8),
        backgroundColor: const Color(0xFFE7F0FF),
        onTap: () => _openPage(
          context,
          const WordToPdfPage(),
        ),
      ),
      ToolModel(
        title: 'Excel\nto PDF',
        icon: Icons.table_chart_rounded,
        iconColor: const Color(0xFF12A968),
        backgroundColor: const Color(0xFFE3F7EE),
        onTap: () => _openPage(
          context,
          const ExcelToPdfPage(),
        ),
      ),
      ToolModel(
        title: 'PPT\nto PDF',
        icon: Icons.slideshow_rounded,
        iconColor: const Color(0xFFFF7100),
        backgroundColor: const Color(0xFFFFEBDD),
        onTap: () => _openPage(
          context,
          const PptToPdfPage(),
        ),
      ),
      ToolModel(
        title: 'Images\nto PDF',
        icon: Icons.image_rounded,
        iconColor: const Color(0xFF8B3DDB),
        backgroundColor: const Color(0xFFF0E5FF),
        onTap: () => _openPage(
          context,
          const ImagesToPdfPage(),
        ),
      ),
    ];

    final convertFromPdfTools = [
      ToolModel(
        title: 'PDF\nto Word',
        icon: Icons.picture_as_pdf_rounded,
        iconColor: const Color(0xFFFF3030),
        backgroundColor: const Color(0xFFFFE6E8),
        onTap: () => _openPage(
          context,
          const PdfToWordPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nto Excel',
        icon: Icons.table_chart_rounded,
        iconColor: const Color(0xFF12A968),
        backgroundColor: const Color(0xFFE3F7EE),
        onTap: () => _openPage(
          context,
          const Pdf_To_ExcelPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nto PPT',
        icon: Icons.slideshow_rounded,
        iconColor: const Color(0xFFFF7100),
        backgroundColor: const Color(0xFFFFEBDD),
        onTap: () => _openPage(
          context,
          const PdfToPptPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nto Images',
        icon: Icons.image_rounded,
        iconColor: const Color(0xFF8B3DDB),
        backgroundColor: const Color(0xFFF0E5FF),
        onTap: () => _openPage(
          context,
          const PdfToImagesPage(),
        ),
      ),
    ];

    final editTools = [
      ToolModel(
        title: 'Edit\nPDF',
        icon: Icons.edit_rounded,
        iconColor: const Color(0xFF8B2CF5),
        backgroundColor: const Color(0xFFF1E5FF),
        onTap: () => _openPage(
          context,
          const Edit_PdfPage(),
        ),
      ),
      ToolModel(
        title: 'Merge\nPDF',
        icon: Icons.merge_type_rounded,
        iconColor: const Color(0xFFFF3048),
        backgroundColor: const Color(0xFFFFE7EA),
        onTap: () => _openPage(
          context,
          const Merge_PdfPage(),
        ),
      ),
      ToolModel(
        title: 'Split\nPDF',
        icon: Icons.grid_view_rounded,
        iconColor: const Color(0xFF146CE8),
        backgroundColor: const Color(0xFFE7F0FF),
        onTap: () => _openPage(
          context,
          const Split_PdfPage(),
        ),
      ),
      ToolModel(
        title: 'Rearrange\nPages',
        icon: Icons.swap_vert_rounded,
        iconColor: const Color(0xFF12A968),
        backgroundColor: const Color(0xFFE3F7EE),
        onTap: () => _openPage(
          context,
          const Rearrange_PagesPage(),
        ),
      ),
    ];

    final moreTools = [
      ToolModel(
        title: 'Compress\nPDF',
        icon: Icons.compress_rounded,
        iconColor: const Color(0xFFFF7100),
        backgroundColor: const Color(0xFFFFEBDD),
        onTap: () => _openPage(
          context,
          const Compress_PdfPage(),
        ),
      ),
      ToolModel(
        title: 'Add\nPassword',
        icon: Icons.lock_outline_rounded,
        iconColor: const Color(0xFF8B2CF5),
        backgroundColor: const Color(0xFFF1E5FF),
        onTap: () => _openPage(
          context,
          const PdfProtectPage(),
        ),
      ),
      ToolModel(
        title: 'Remove\nPassword',
        icon: Icons.lock_open_rounded,
        iconColor: const Color(0xFF12A968),
        backgroundColor: const Color(0xFFE3F7EE),
        onTap: () => _openPage(
          context,
          const PdfUnlockPage(),
        ),
      ),
      ToolModel(
        title: 'Rotate\nPages',
        icon: Icons.rotate_right_rounded,
        iconColor: const Color(0xFFFF3048),
        backgroundColor: const Color(0xFFFFE7EA),
        onTap: () => _openPage(
          context,
          const Rotate_PagesPage(),
        ),
      ),
      ToolModel(
        title: 'Crop\nPDF',
        icon: Icons.crop_rounded,
        iconColor: const Color(0xFF146CE8),
        backgroundColor: const Color(0xFFE7F0FF),
        onTap: () => _openPage(
          context,
          const Crop_PdfPage(),
        ),
      ),
      ToolModel(
        title: 'Extract\nPages',
        icon: Icons.content_copy_rounded,
        iconColor: const Color(0xFFFF3048),
        backgroundColor: const Color(0xFFFFE7EA),
        onTap: () => _openPage(
          context,
          const Extract_PagesPage(),
        ),
      ),
      ToolModel(
        title: 'Delete\nPages',
        icon: Icons.delete_outline_rounded,
        iconColor: const Color(0xFFFFB000),
        backgroundColor: const Color(0xFFFFF4D9),
        onTap: () => _openPage(
          context,
          const Delete_PagesPage(),
        ),
      ),
      ToolModel(
        title: 'PDF\nInfo',
        icon: Icons.info_outline_rounded,
        iconColor: const Color(0xFF146CE8),
        backgroundColor: const Color(0xFFE7F0FF),
        onTap: () => _openPage(
          context,
          const Pdf_InfoPage(),
        ),
      ),
      ToolModel(
        title: 'Add\nWatermark',
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFF8B2CF5),
        backgroundColor: const Color(0xFFF1E5FF),
        onTap: () => _openPage(
          context,
          const WatermarkPage(),
        ),
      ),
      ToolModel(
        title: 'Number\nPages',
        icon: Icons.filter_9_plus_rounded,
        iconColor: const Color(0xFFFF3048),
        backgroundColor: const Color(0xFFFFE7EA),
        onTap: () => _openPage(
          context,
          const Number_PagesPage(),
        ),
      ),
      ToolModel(
        title: 'Add\nPage',
        icon: Icons.add_circle_outline_rounded,
        iconColor: const Color(0xFF12A968),
        backgroundColor: const Color(0xFFE3F7EE),
        onTap: () => _openPage(
          context,
          const Add_PagePage(),
        ),
      ),
      ToolModel(
        title: 'Duplicate\nPages',
        icon: Icons.library_add_rounded,
        iconColor: const Color(0xFFFF7100),
        backgroundColor: const Color(0xFFFFEBDD),
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFF8F9FD),
              padding: const EdgeInsets.fromLTRB(
                18,
                14,
                18,
                12,
              ),
              child: const Text(
                'All Tools',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101631),
                  letterSpacing: -0.8,
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ToolSection(
                        title: 'Popular Tools',
                        tools: popularTools,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ToolSection(
                        title: 'Convert to PDF',
                        tools: convertToPdfTools,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ToolSection(
                        title: 'Convert from PDF',
                        tools: convertFromPdfTools,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ToolSection(
                        title: 'Edit & Organize',
                        tools: editTools,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ToolSection(
                        title: 'More Tools',
                        tools: moreTools,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}