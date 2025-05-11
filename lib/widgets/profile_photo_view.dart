import 'package:flutter/material.dart';

class ProfilePhotoView extends StatelessWidget {
  final String profilePhotoUrl;

  const ProfilePhotoView({super.key, required this.profilePhotoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(profilePhotoUrl),
      radius: 50,
    );
  }
}
