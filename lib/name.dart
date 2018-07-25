import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
part 'name.g.dart';
@JsonSerializable()
class UserName{
  String name;
  int id;

  UserName(this.name){
    Random generator = new Random();
    this.id = 10000+generator.nextInt(90000);
  }

  factory UserName.fromJson(Map<String, dynamic> json) => _$UserNameFromJson(json);

  Map<String, dynamic> toJson() =>{
    'name': name,
    'id': id,
  };
}