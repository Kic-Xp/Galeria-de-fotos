import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart'; // Use universal_io
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'fullscreen_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotoGalleryProvider(),
      child: MaterialApp(
        title: 'Galeria de Fotos',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PhotoGalleryScreen(),
      ),
    );
  }
}

class PhotoGalleryProvider extends ChangeNotifier {
  List<XFile> _photos = [];

  List<XFile> get photos => _photos;

  void addPhoto(XFile photo) {
    _photos.add(photo);
    notifyListeners();
  }

  void removePhoto(int index) {
    _photos.removeAt(index);
    notifyListeners();
  }
}

class PhotoGalleryScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Galeria De Fotos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<PhotoGalleryProvider>(
          builder: (context, gallery, child) {
            return AnimationLimiter(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: gallery.photos.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 3,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                  imagePath: gallery.photos[index].path,
                                  isWeb: kIsWeb,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              if (kIsWeb)
                                CachedNetworkImage(
                                  imageUrl: gallery.photos[index].path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      'Falha ao Carregar imagem, tente outra imagem.',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              else
                                Image.file(
                                  File(gallery.photos[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return Center(
                                      child: Text(
                                        'Falha ao Carregar imagem, tente outra imagem.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    context.read<PhotoGalleryProvider>().removePhoto(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
          if (photo != null) {
            context.read<PhotoGalleryProvider>().addPhoto(photo);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
