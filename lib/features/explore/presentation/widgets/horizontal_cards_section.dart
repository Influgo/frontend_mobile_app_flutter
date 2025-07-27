import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/influencer_grid_view_page.dart';
import 'grid_view_page.dart'; // Importar la nueva página

class HorizontalCardsSection extends StatefulWidget {
  final String title;
  final List<Widget> cards;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  // Nuevas propiedades para el "Ver más"
  final List<Entrepreneurship>?
      allEntrepreneurships; // Lista completa para la vista cuadricular

  final List<Influencer>?
      allInfluencers;
  final VoidCallback?
      onLoadMoreGrid; // Callback para cargar más en la vista cuadricular

  const HorizontalCardsSection({
    super.key,
    required this.title,
    required this.cards,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.allEntrepreneurships,
    this.allInfluencers,
    this.onLoadMoreGrid,
  });

  @override
  _HorizontalCardsSectionState createState() => _HorizontalCardsSectionState();
}

class _HorizontalCardsSectionState extends State<HorizontalCardsSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.onLoadMore != null &&
        !widget.isLoadingMore &&
        widget.hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
      widget.onLoadMore!();
    }
  }

  void _navigateToGridView() {
    if (widget.allEntrepreneurships != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GridViewPage(
            title: widget.title,
            entrepreneurships: widget.allEntrepreneurships!,
            onLoadMore: widget.onLoadMoreGrid,
            isLoadingMore: widget.isLoadingMore,
            hasMore: widget.hasMore,
          ),
        ),
      );
    }
  }

  void _navigateToGridViewInfluencer() {
    if (widget.allInfluencers != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InfluencerGridViewPage(
            title: widget.title,
            influencers: widget.allInfluencers!,
            onLoadMore: widget.onLoadMoreGrid,
            isLoadingMore: widget.isLoadingMore,
            hasMore: widget.hasMore,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowIndicatorSlot =
        widget.isLoadingMore || (widget.hasMore && widget.onLoadMore != null);
    int effectiveItemCount =
        widget.cards.length + (shouldShowIndicatorSlot ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con "Ver más"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              // Botón "Ver más"
              if (widget.allEntrepreneurships != null &&
                  widget.allEntrepreneurships!.isNotEmpty)
                GestureDetector(
                  onTap: _navigateToGridView,
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

              if (widget.allInfluencers != null &&
                  widget.allInfluencers!.isNotEmpty)
                GestureDetector(
                  onTap: _navigateToGridViewInfluencer,
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Lista horizontal de tarjetas
        SizedBox(
          height: 220, // Aumentado de 190 a 220 para acomodar las tarjetas más grandes
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: effectiveItemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < widget.cards.length) {
                return SizedBox(
                  width: 170, // Aumentado de 150 a 170 para coincidir con el ancho de las tarjetas de influencer
                  child: widget.cards[index],
                );
              } else if (shouldShowIndicatorSlot) {
                if (widget.isLoadingMore) {
                  return Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2.0),
                  );
                } else if (widget.hasMore && widget.onLoadMore != null) {
                  return const SizedBox(width: 50);
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
