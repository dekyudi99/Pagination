import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pagination/models/errMsg.dart';
import 'package:pagination/models/kelompok.dart';
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
  File? _selectedImage;
  final _picker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  String idKelompok='';
  String? _selectedStatus;
  String idPenjual='';
  late ErrorMSG response;
  // bool _isupdate=false;
  // bool _validate=false;
  bool _success=false;
  List<Kelompok> _kelompok=[];
  String _imagePath='';
  // final List<String> _kelompokOptions = ['Kelompok A', 'Kelompok B', 'Kelompok C'];
  final List<String> _statusOptions = ['Y', 'T'];

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
         _selectedImage = File(picked.path);
        _imagePath=picked.path;
      });
    }
  }
  void getKelompok() async {
  final response = await Apipetani.getKelompokTani();
    setState(() {
        _kelompok=response.toList();
      });
  }
 void _submit() async{
    if(_formKey.currentState!.validate()){      
      _formKey.currentState!.save();
      var params =  {
          'nama':_namaController.text.toString(),
          'nik':_nikController.text.toString(),
          'alamat' : _alamatController.text.toString(),
          'telp' :_telpController.text.toString(),
          'status':_selectedStatus,
          'id_kelompok_tani' :idKelompok,
        }; 
        response=await Apipetani.savePetani(idPenjual,params,_imagePath);
        _success=response.success;
        final snackBar = SnackBar(content: Text(response.message),);        
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (_success) {
          Navigator.pop(context, true); 
        }
    }else {
      // _validate = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getKelompok();
    if (widget.petani != null) {
      idPenjual=widget.petani!.idPenjual;
      _namaController.text = widget.petani!.nama;
      _nikController.text = widget.petani!.nik;
      _alamatController.text = widget.petani!.alamat;
      _telpController.text = widget.petani!.telp;
      idKelompok = widget.petani!.idKelompokTani;
      _selectedStatus = widget.petani!.status;

      if (_kelompok.contains(widget.petani!.idKelompokTani)) {
        idKelompok = widget.petani!.idKelompokTani ;
      }

      if (_statusOptions.contains(widget.petani!.status)) {
        _selectedStatus = widget.petani!.status;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Petani')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(child: Text('Pilih Foto')),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _nikController,
                decoration: InputDecoration(labelText: 'NIK'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _telpController,
                decoration: InputDecoration(labelText: 'Telepon'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: DropdownButtonFormField(
                  value: idKelompok==''?null:idKelompok,
                  hint: Text("Pilih Kelompok"),
                  decoration: const InputDecoration(
                      icon: Icon(Icons.category_rounded),
                    ),
                  items: _kelompok.map((item) {
                      return DropdownMenuItem(
                        child: Text(item.namaKelompok),
                        value: item.idKelompokTani,
                      );
                    }).toList(),
                  onChanged: (value){
                    setState(() {
                        idKelompok=value.toString();
                      });
                  },
                  validator: (u) => u == null ? "Wajib Diisi " : null,
                ),
              ),
              Row(
                children: [
                  Text("Status: "),
                  SizedBox(width: 8,),
                  Radio<String>(
                    value: 'Y',
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  Text('Aktif'),

                  Radio<String>(
                    value: 'N',
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  Text('Tidak Aktif'),
                ],
              ),
              // DropdownButtonFormField<String>(
              //   value: _selectedStatus,
              //   decoration: InputDecoration(labelText: 'Status'),
              //   items: _statusOptions
              //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              //       .toList(),
              //   onChanged: (val) => setState(() => _selectedStatus = val),
              //   validator: (value) => value == null ? 'Pilih salah satu' : null,
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}