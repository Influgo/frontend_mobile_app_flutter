import 'package:flutter/material.dart';

class HorizontalCardsSection extends StatefulWidget {
  final String title;
  final List<Widget> cards;
  final VoidCallback? onLoadMore; // Callback para cargar más
  final bool isLoadingMore;      // Para mostrar un indicador de carga
  final bool hasMore;            // Para saber si se puede cargar más

  const HorizontalCardsSection({
    super.key,
    required this.title,
    required this.cards,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  _HorizontalCardsSectionState createState() => _HorizontalCardsSectionState();
}

class _HorizontalCardsSectionState extends State<HorizontalCardsSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Añadimos el listener para el scroll
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Es importante remover el listener y disponer el controller
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Si hay una función para cargar más, no estamos cargando actualmente,
    // se indica que hay más datos disponibles, y el scroll está cerca del final.
    if (widget.onLoadMore != null &&
        !widget.isLoadingMore &&
        widget.hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) { // Umbral de 100px desde el final
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si se debe mostrar el slot para el indicador (loader o espacio de "hasMore").
    // Se muestra si está cargando, O si hay más datos y una función para cargar (lo que implica que la carga por scroll está habilitada).
    bool shouldShowIndicatorSlot = widget.isLoadingMore || (widget.hasMore && widget.onLoadMore != null);
    
    // El itemCount será la cantidad de tarjetas + 1 si el slot del indicador debe mostrarse.
    int effectiveItemCount = widget.cards.length + (shouldShowIndicatorSlot ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título (mantenido como en tu código original)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              //fontWeight: FontWeight.bold, // Mantenido comentado como en tu original
            ),
          ),
        ),
        const SizedBox(height: 12), // Espaciador vertical original

        // Lista horizontal de tarjetas
        SizedBox(
          height: 190, // Altura original del contenedor de la lista
          child: ListView.separated(
            controller: _scrollController, // Asignar el ScrollController
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding original del ListView
            scrollDirection: Axis.horizontal,
            itemCount: effectiveItemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 12), // Separador original
            itemBuilder: (context, index) {
              // Si el índice actual corresponde a una de las tarjetas de datos
              if (index < widget.cards.length) {
                return SizedBox(
                  width: 150, // Ancho original para cada tarjeta
                  child: widget.cards[index],
                );
              } 
              // Si el índice corresponde al slot del indicador (que está después de todas las tarjetas)
              else if (shouldShowIndicatorSlot) { 
                if (widget.isLoadingMore) {
                  // Si está cargando, mostrar un CircularProgressIndicator.
                  // Usamos un Container para darle un ancho y centrarlo.
                  return Container(
                    width: 50, // Ancho para el área del loader
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2.0),
                  );
                } else if (widget.hasMore && widget.onLoadMore != null) {
                  // Si hay más por cargar pero NO se está cargando activamente,
                  // mostramos un SizedBox. Esto es útil para la carga automática por scroll,
                  // ya que asegura que haya contenido al final para que el _scrollListener
                  // pueda detectar que se llegó al final del scroll.
                  // Si prefirieses un botón "Cargar más" explícito, iría aquí.
                  return const SizedBox(width: 50); // Espacio para asegurar que el scroll pueda activar el listener
                }
              }
              // Fallback (no debería alcanzarse si la lógica de itemCount es correcta)
              return const SizedBox.shrink(); 
            },
          ),
        ),
      ],
    );
  }
}
