import 'package:meta/meta.dart';

final demoPlaylist = new DemoPlaylist(
  songs: [
    new DemoSong(
      audioUrl: 'http://m10.music.126.net/20180918175821/0c251fb84af613d5146d66d6235d9ae2/ymusic/6829/d60c/b0d4/016b68b477333c1a9350fc2acacf8a3c.mp3',
      albumArtUrl: 'https://p1.music.126.net/7Byt265s3FEu0SJvNp4ORQ==/109951163464499716.jpg?param=200y200',
      songTitle: '肥宅群侠传(Live)',
      artist: '上海彩虹室内合唱团',
    ),
    new DemoSong(
      audioUrl: 'http://m10.music.126.net/20180918175918/6c80267bcb7c86efb7dab19fcb7cde4a/ymusic/4f98/08d9/7e1d/db7ecc48be6662e7f16a2ea07086409d.mp3',
      albumArtUrl: 'https://p1.music.126.net/EdTfeOrqoB79jg3f0CGCqw==/109951163036911274.jpg?param=200y200',
      songTitle: '放弃治疗',
      artist: 'Serrini',
    ),
  ],
);

class DemoPlaylist {

  final List<DemoSong> songs;

  DemoPlaylist({
    @required this.songs,
  });

}

class DemoSong {

  final String audioUrl;
  final String albumArtUrl;
  final String songTitle;
  final String artist;

  DemoSong({
    @required this.audioUrl,
    @required this.albumArtUrl,
    @required this.songTitle,
    @required this.artist,
  });

}