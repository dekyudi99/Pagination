import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pagination/models/model.dart';
import 'package:pagination/service/apiPetani.dart';
import 'package:pagination/pages/petaniForm.dart';
import 'package:pagination/pages/detailPetaniPage.dart';

class PetaniPage extends StatefulWidget {
  const PetaniPage({super.key});

  @override
  State<PetaniPage> createState() => _PetaniPageState();
}

class _PetaniPageState extends State<PetaniPage> {
  late final _pagingController = PagingController<int, Petani>(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) => Apipetani.getPetaniFilter(pageKey, '', 'Y'),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Petani"),
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        actions: [Icon(Icons.person_2_outlined)],
      ),
      body: PagingListener<int, Petani>(
        controller: _pagingController,
        builder:
            (context, state, fetchNextPage) => PagedListView(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<Petani>(
                itemBuilder: (context, item, index) => Card(
                  child: ListTile(
                    title: Text(item.nama),
                    subtitle: Text(item.alamat),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPetaniPage(petani: item),
                        ),
                      );
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PetaniFormPage(petani: item)),
                          );
                          if (refresh == true) _pagingController.refresh();
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Hapus Petani'),
                              content: Text('Yakin ingin menghapus data ini?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final success = await Apipetani.deletePetani(item.idPenjual);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil dihapus")));
                              _pagingController.refresh();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus")));
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ),
                )
              ),
            ),
      ),
      // Tambah Petani
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PetaniFormPage()),
          );
          if (refresh == true) {
            _pagingController.refresh();
          }
        },
      ),
    );
  }
}
