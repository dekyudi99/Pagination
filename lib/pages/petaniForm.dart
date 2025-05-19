import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pagination/models/model.dart';
import 'package:pagination/service/apiPetani.dart';

class PetaniFormPage extends StatefulWidget {
  final Petani? petani;

  const PetaniFormPage({super.key, this.petani});

  @override
  State<PetaniFormPage> createState() => _PetaniFormPageState();
}

class _PetaniFormPageState extends State<PetaniFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _telpController;
  String _status = "Y";
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final p = widget.petani;
    _namaController = TextEditingController(text: p?.nama ?? '');
    _nikController = TextEditingController(text: p?.nik ?? '');
    _alamatController = TextEditingController(text: p?.alamat ?? '');
    _telpController = TextEditingController(text: p?.telp ?? '');
    _status = p?.status ?? "Y";
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      final petani = Petani(
        idPenjual: widget.petani?.idPenjual ?? '',
        nama: _namaController.text,
        nik: _nikController.text,
        alamat: _alamatController.text,
        telp: _telpController.text,
        foto: '', // akan ditangani via multipart
        idKelompokTani: '1',
        status: _status,
        namaKelompok: '',
        createdAt: '',
        updatedAt: '',
      );

      bool success = false;

      if (widget.petani == null && _selectedImage != null) {
        success = await Apipetani.createPetaniWithImage(petani, _selectedImage!);
      } else if (widget.petani != null) {
        success = await Apipetani.updatePetani(widget.petani!.idPenjual, petani);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil disimpan')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.petani != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Petani' : 'Tambah Petani')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _namaController, decoration: InputDecoration(labelText: 'Nama')),
              TextFormField(controller: _nikController, decoration: InputDecoration(labelText: 'NIK')),
              TextFormField(controller: _alamatController, decoration: InputDecoration(labelText: 'Alamat')),
              TextFormField(controller: _telpController, decoration: InputDecoration(labelText: 'Telepon')),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Y', 'N'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _pickImage, child: Text('Pilih Foto')),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_selectedImage!, height: 80),
                ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _simpan, child: Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}