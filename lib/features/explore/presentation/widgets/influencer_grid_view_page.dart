import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/influencer_card_widget.dart';

class InfluencerGridViewPage extends StatefulWidget {
  final String title;
  final List<Influencer> influencers;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const InfluencerGridViewPage({
    super.key,
    required this.title,
    required this.influencers,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  _InfluencerGridViewPageState createState() => _InfluencerGridViewPageState();
}

class _InfluencerGridViewPageState extends State<InfluencerGridViewPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: widget.influencers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay influencers para mostrar'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columnas
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 150 /
                          190, // Mantener proporción del InfluencerCardWidget
                    ),
                    itemCount: widget.influencers.length +
                        (widget.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < widget.influencers.length) {
                        return InfluencerCardWidget(
                          influencer: widget.influencers[index],
                        );
                      } else if (widget.isLoadingMore) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (widget.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
