import 'dart:io';

import '../models/profile.dart';
import 'api_client.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<MyProfile> updateProfile({String? name, String? bio, String? gender, String? interestedIn}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (bio != null) body['bio'] = bio;
    if (gender != null) body['gender'] = gender;
    if (interestedIn != null) body['interested_in'] = interestedIn;

    final response = await _client.put('/api/users/me', body: body);
    return MyProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<Photo> uploadPhoto(File file) async {
    final response = await _client.uploadFile('/api/users/me/photos', file);
    return Photo.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deletePhoto(int photoId) async {
    await _client.delete('/api/users/me/photos/$photoId');
  }
}
