class Photo {
  final int id;
  final String url;
  final int position;

  Photo({required this.id, required this.url, required this.position});

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as int,
        url: json['url'] as String,
        position: json['position'] as int,
      );
}

/// The current user's own full profile (includes email).
class MyProfile {
  final int id;
  final String email;
  final String name;
  final String birthdate;
  final String gender;
  final String interestedIn;
  final String bio;
  final List<Photo> photos;

  MyProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.birthdate,
    required this.gender,
    required this.interestedIn,
    required this.bio,
    required this.photos,
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) => MyProfile(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
        birthdate: json['birthdate'] as String,
        gender: json['gender'] as String,
        interestedIn: json['interested_in'] as String,
        bio: json['bio'] as String,
        photos: (json['photos'] as List)
            .map((p) => Photo.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

/// A profile shown to other users while discovering/matching (no email).
class PublicProfile {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String bio;
  final List<Photo> photos;

  PublicProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.photos,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
        id: json['id'] as int,
        name: json['name'] as String,
        age: json['age'] as int,
        gender: json['gender'] as String,
        bio: json['bio'] as String,
        photos: (json['photos'] as List)
            .map((p) => Photo.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
