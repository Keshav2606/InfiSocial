import 'package:image_picker/image_picker.dart';

Future pickImage({required bool isCamera}) async {
  XFile? image;

  if (isCamera) {
    image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
  } else {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
  }
  return image;
}
