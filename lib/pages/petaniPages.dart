import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pagination/models/model.dart';
import 'package:pagination/service/apiPetani.dart';
import 'package:pagination/pages/petaniForm.dart';
import 'package:pagination/pages/loginPage.dart';

class PetaniPage extends StatefulWidget {
  const PetaniPage({super.key});

  @override
  State<PetaniPage> createState() => _PetaniPageState();
}

class _PetaniPageState extends State<PetaniPage> {
  static const _pageSize = 10;

  final PagingController<int, Petani> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await Apipetani.getPetaniFilter(
        pageKey,
        _searchKeyword,
        'Y',
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _refreshSearch() {
    setState(() {
      _searchKeyword = _searchController.text;
    });
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Petani"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Apipetani.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Petani',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _refreshSearch,
                ),
              ),
              onSubmitted: (_) => _refreshSearch(),
            ),
          ),
          Expanded(
            child: PagedListView<int, Petani>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Petani>(
                itemBuilder: (context, item, index) => Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: ListTile(
                    title: Text(item.nama),
                    subtitle: Text(item.alamat),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetaniFormPage(petani: item),
                              ),
                            );
                            if (result == true) {
                              _pagingController.refresh();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: const Text(
                                    'Apakah Anda yakin ingin menghapus data ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success =
                                  await Apipetani.deletePetani(item.idPenjual);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Data berhasil dihapus')),
                                );
                                _pagingController.refresh();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Gagal menghapus data')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                noItemsFoundIndicatorBuilder: (_) => const Center(
                  child: Text('Tidak ada data ditemukan.'),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetaniFormPage(),
            ),
          );
          if (result == true) {
            _pagingController.refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}