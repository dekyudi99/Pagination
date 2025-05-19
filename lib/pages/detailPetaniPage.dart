import 'package:flutter/material.dart';
import 'package:pagination/models/model.dart';

class DetailPetaniPage extends StatelessWidget {
  final Petani petani;

  const DetailPetaniPage({super.key, required this.petani});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Petani')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${petani.nama}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('NIK: ${petani.nik}'),
            Text('Alamat: ${petani.alamat}'),
            Text('Telepon: ${petani.telp}'),
            Text('Status: ${petani.status}'),
            SizedBox(height: 16),
            if (petani.foto.isNotEmpty)
              Image.network('http://dev.wefgis.com/storage/${petani.foto}', height: 200),
          ],
        ),
      ),
    );
  }
}