class Kelompok {
    Kelompok({
      required  this.idKelompokTani,
      required  this.namaKelompok,
    });
    String idKelompokTani;
    String namaKelompok;
    factory Kelompok.fromJson(Map<String, dynamic> json) => Kelompok(
        idKelompokTani: json["id_kelompok_tani"].toString(),
        namaKelompok: json["nama_kelompok"]==null?'':json["nama_kelompok"].toString()
    );
    Map<String, dynamic> toJson() => {
        "id_kelompok_tani": idKelompokTani,
        "nama_kelompok": namaKelompok,
    };
}