import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Hive için kod üretimi

@HiveType(typeId: 0) // Tip ID: 0 (veritabanındaki tanım numarası)
class UserModel extends HiveObject {
  @HiveField(0)
  late String ad;

  @HiveField(1)
  late String soyad;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String sifre;

  @HiveField(4)
  String? profilFoto; // Opsiyonel (seçerse)

  UserModel({
    required this.ad,
    required this.soyad,
    required this.email,
    required this.sifre,
    this.profilFoto,
  });
}
