import 'dart:async';

import 'package:meta/meta.dart';
import 'dart:io';
import 'dart:convert';

var demoPlaylist = new DemoPlaylist();

class DemoPlaylist {


  List<DemoSong> songs=new List<DemoSong>();

  Future<void> getFavSongs() async{
    var url='http://szugreenwind.club:3000/playlist/detail?id=51061516';
    var httpClient=new HttpClient();

    try{
      var request=await httpClient.getUrl(Uri.parse(url));
      var response=await request.close();
      if(response.statusCode==HttpStatus.OK){
        var jsondata=await response.transform(utf8.decoder).join();
        var data=json.decode(jsondata);
        var musicUrl='http://szugreenwind.club:3000/music/url?id=';
        for(int i=0;i<10;++i){
          if(i==9){
            musicUrl=musicUrl+data['playlist']['tracks'][i]['id'].toString();
          }else{
            musicUrl=musicUrl+data['playlist']['tracks'][i]['id'].toString()+',';
          }
          songs.add(new DemoSong(audioUrl: '', albumArtUrl: data['playlist']['tracks'][i]['al']['picUrl']+'?param=200y200', songTitle: data['playlist']['tracks'][i]['name'], artist: data['playlist']['tracks'][i]['ar'][0]['name'],id: data['playlist']['tracks'][i]['id']));
        }

        var musicRequest=await httpClient.getUrl(Uri.parse(musicUrl));
        var musicRespone=await musicRequest.close();
        if(musicRespone.statusCode==HttpStatus.OK){
          var musicjsondata=await musicRespone.transform(utf8.decoder).join();
          var musicdata=json.decode(musicjsondata);
          for(int i=0;i<10;++i){
            for(int j=0;j<10;++j){
              if(musicdata['data'][i]['id']==songs.elementAt(j).id){
                songs.elementAt(j).audioUrl=musicdata['data'][i]['url'];
                break;
              }else{
                continue;
              }
            }
          }
        }

      }
    }catch(e){
      print(e.toString());
      songs.add(new DemoSong(audioUrl: '', albumArtUrl: '', songTitle: 'NonNetWork', artist: 'NonNetWork'));
    }
  }


}


class DemoSong {

  String audioUrl;
  final String albumArtUrl;
  final String songTitle;
  final String artist;
  final int id;

  DemoSong({
    @required this.audioUrl,
    @required this.albumArtUrl,
    @required this.songTitle,
    @required this.artist,
    this.id
  });

}