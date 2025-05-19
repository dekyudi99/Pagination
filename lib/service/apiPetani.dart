import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pagination/models/model.dart';

class Apipetani {
  static final host = 'http://dev.wefgis.com';
  static var _token = "8|x6bKsHp9STb0uLJsM11GkWhZEYRWPbv0IqlXvFi7";

  static Future<List<Petani>> getPetaniFilter(
    int pageKey,
    String _s,
    String _selectedChoice,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$host/api/petani?page=" +
              pageKey.toString() +
              "&s=" +
              _s +
              "&publish=" +
              _selectedChoice,
        ),
        headers: {'Authorization': 'Bearer ' + _token},
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        //print(json);
        final parsed = json['data'].cast<Map<String, dynamic>>();
        return parsed.map<Petani>((json) => Petani.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createPetaniWithImage(
    Petani petani,
    File imageFile,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$host/api/petani"),
      );
      request.headers['Authorization'] = 'Bearer $_token';

      request.fields['nama'] = petani.nama;
      request.fields['nik'] = petani.nik;
      request.fields['alamat'] = petani.alamat;
      request.fields['telp'] = petani.telp;
      request.fields['id_kelompok_tani'] = petani.idKelompokTani;
      request.fields['status'] = petani.status;

      request.files.add(
        await http.MultipartFile.fromPath('foto', imageFile.path),
      );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updatePetani(String id, Petani petani) async {
    try {
      final response = await http.put(
        Uri.parse("$host/api/petani/$id"),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "nama": petani.nama,
          "nik": petani.nik,
          "alamat": petani.alamat,
          "telp": petani.telp,
          "foto": petani.foto,
          "id_kelompok_tani": petani.idKelompokTani,
          "status": petani.status,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete Petani
  static Future<bool> deletePetani(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$host/api/petani/$id"),
        headers: {'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
