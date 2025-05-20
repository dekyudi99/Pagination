import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pagination/models/kelompok.dart';
import 'package:pagination/models/model.dart';
import 'package:pagination/models/errMsg.dart';

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

  static Future<ErrorMSG> savePetani(id, petani, filepath) async {
    try {
      var url=Uri.parse('$host/api/petani');
      if(id != ''){
        url=Uri.parse('$host/api/petani/'+id);
      }    
      final request = http.MultipartRequest('POST', url)
      ..fields['nama'] = petani['nama']
      ..fields['nik'] = petani['nik']
      ..fields['alamat'] = petani['alamat']
      ..fields['telp'] = petani['telp']
      ..fields['id_kelompok_tani'] = petani['id_kelompok_tani']
      ..fields['status'] = petani['status'];

    if(filepath!=''){
        request.files.add(await http.MultipartFile.fromPath('foto', filepath));
      }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {

          //print(jsonDecode(respStr));
          return ErrorMSG.fromJson(jsonDecode(responseBody));
        } else {
          //return ErrorMSG.fromJson(jsonDecode(response.body));
          return ErrorMSG(success: false,message: 'err Request');
        }
    } catch (e) {
      ErrorMSG responseRequest = ErrorMSG(success: false,message: 'error caught : $e');
      return responseRequest;
    }    
  }

  static Future<bool> updatePetani(Petani petani) async {
    try {
      final response = await http.put(
        Uri.parse("https://dev.wefgis.com/api/petani/${petani.idPenjual}"),
        body: jsonEncode(petani.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to update petani: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception updatePetani: $e');
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

  static Future<List<Kelompok>> getKelompokTani() async {
    try {
      final response= await http.get(Uri.parse("$host/api/kelompoktani"),
      headers: {
        'Authorization':'Bearer '+_token,
      });      
      if (response.statusCode==200) {
        var json=jsonDecode(response.body);
        final parsed=json.cast<Map<String, dynamic>>();
        return parsed.map<Kelompok>((json)=>Kelompok.fromJson(json)).toList();
      } else {
        return [];
      }
      } catch (e) {
        return [];
    }
  }

}
