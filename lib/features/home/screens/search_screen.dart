import 'package:flutter/material.dart';
import 'package:thrift_corner/features/home/screens/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final List products;

  const SearchScreen({super.key, required this.products});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  List filteredProducts = [];
  @override
  void initState() {
    super.initState();
    filteredProducts = [];
  }

  void searchProducts(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredProducts = List.from(widget.products);
      } else {
        filteredProducts = widget.products.where((product) {
          return product['title'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Search Products'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              controller: searchController,

              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.grey.shade500),

                prefixIcon: const Icon(Icons.search, color: Colors.black54),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            filteredProducts = [];
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.4,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: searchController.text.isEmpty
                  ? const SizedBox()
                  : Text(
                      "${filteredProducts.length} Results",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: searchController.text.isEmpty
                ? const Center(
                    child: Text(
                      "Search for products",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No Products Found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    product['thumbnail'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['title'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      '\$${product['price']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
