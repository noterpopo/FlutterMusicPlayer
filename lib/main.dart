import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_music_player/bottom_controls.dart';
import 'package:flutter_music_player/songs.dart';
import 'package:flutter_music_player/teme.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return new AudioPlaylist(
      playlist: demoPlaylist.songs.map((DemoSong song){
        return song.audioUrl;
      }).toList(growable: false),
      playbackState: PlaybackState.paused,
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios
            ),
            color: const Color(0xFFDDDDDD),
            onPressed: (){},
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(
                  Icons.menu
              ),
              color: const Color(0xFFDDDDDD),
              onPressed: (){},
            ),
          ],
        ),
        body: new Column(
          children: <Widget>[
            //seek bar
            new Expanded(
              child: new AudioPlaylistComponent(
                playlistBuilder: (BuildContext context,Playlist playlist,Widget child){
                  String albumArtUrl=demoPlaylist.songs[playlist.activeIndex].albumArtUrl;
                  return new AudioRadialSeekBar(
                    alnumArtUrl:albumArtUrl,
                  );
                },
              ),
            ),

            //visual
            new Container(
              width: double.infinity,
              height: 125.0,
              child: new Visualizer(
                builder: (BuildContext context,List<int> fft){
                  return new CustomPaint(
                    painter: new VisualizerPainter(
                      fft: fft,
                      height: 125.0,
                      color: accentColor,
                    ),
                    child: new Container(),
                  );
                },
              ),
            ),

            //inf
            new BottomControl()
          ],
        ),
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter{

  final List<int> fft;
  final double height;
  final Color color;
  final Paint wavePaint;

  VisualizerPainter({
    this.fft,
    this.height,
    this.color,
  }):wavePaint=new Paint()
    ..color=color.withOpacity(0.5)
    ..style=PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      wavePaint
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AudioRadialSeekBar extends StatefulWidget {

  final String alnumArtUrl;


  AudioRadialSeekBar({this.alnumArtUrl});

  @override
  AudioRadialSeekBarState createState() {
    return new AudioRadialSeekBarState();
  }
}

class AudioRadialSeekBarState extends State<AudioRadialSeekBar> {

  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    return new AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayhead,
        WatchableAudioProperties.audioSeeking,
      ],
      playerBuilder: (BuildContext context,AudioPlayer player,Widget child){

        double playbackProgress=0.0;
        if(player.audioLength!=null&&player.position!=null){
          playbackProgress=player.position.inMilliseconds/player.audioLength.inMilliseconds;
        }

        _seekPercent=player.isSeeking?_seekPercent:null;

        return new RadiaSeekBar(
          progress: playbackProgress,
          seekPercent: _seekPercent,
          onSeekRequested: (double seekPercent){
            setState(()=>_seekPercent=seekPercent);
            final seekMills=(player.audioLength.inMilliseconds*seekPercent).round();
            player.seek(new Duration(milliseconds: seekMills));
          },
          child:new Container(
            color: accentColor,
            child: new Image.network(widget.alnumArtUrl,fit: BoxFit.cover,),
          )
        );
      },
    );
  }
}

class RadiaSeekBar extends StatefulWidget {

  final double progress;
  final double seekPercent;
  final Function(double) onSeekRequested;
  final Widget child;


  RadiaSeekBar({
    this.seekPercent=0.0,
    this.progress=0.0,
    this.onSeekRequested,
    this.child
  });

  @override
  RadiaSeekBarState createState() {
    return new RadiaSeekBarState();
  }
}

class RadiaSeekBarState extends State<RadiaSeekBar> {

  double _progress=0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currrentDragPercent;

  void _onDragStart(PolarCoord coord){
    _startDragCoord=coord;
    _startDragPercent=_progress;
  }

  void _onDragUpdate(PolarCoord coord){
    final dragAngle=coord.angle-_startDragCoord.angle;
    final dragPercent=dragAngle/(2*pi);

    setState(() {
      _currrentDragPercent=(_startDragPercent+dragPercent)%1.0;
    });
  }

  void _onDragEnd(){
    if(widget.onSeekRequested!=null){
      widget.onSeekRequested(_currrentDragPercent);
    }
    setState(() {
      _currrentDragPercent=null;
      _startDragCoord=null;
      _startDragPercent=0.0;
    });
  }


  @override
  void initState() {
    super.initState();
    _progress=widget.progress;
  }


  @override
  void didUpdateWidget(RadiaSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress=widget.progress;
  }

  @override
  Widget build(BuildContext context) {

    double thumbPosition=_progress;
    if(_currrentDragPercent!=null){
      thumbPosition=_currrentDragPercent;
    }else if(widget.seekPercent!=null){
      thumbPosition=widget.seekPercent;
    }

    return new RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: new Container(
        width:double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(
          child: new Container(
            width: 140.0,
            height: 140.0,
            child: new RadialProgressBar(
              trackColor: const Color(0xFFDDDDDD),
              progressPercent: _progress,
              thumbPosition: thumbPosition,
              progressColor: accentColor,
              thumbColor: lightAccentColor,
              innerPadding: const EdgeInsets.all(10.0),
              child: new ClipOval(
                clipper: new CircleClipper(),
                  child:widget.child),
            ),
          ),
        ),
      ),
    );
  }
}



class CircleClipper extends CustomClipper<Rect>{

  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center:new Offset(size.width/2, size.height/2),
      radius:min(size.width,size.height)/2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }

}

class RadialProgressBar extends StatefulWidget {

  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;


  RadialProgressBar({
    this.trackWidth=3.0,
    this.trackColor=Colors.grey,
    this.progressWidth=5.0,
    this.progressColor=Colors.black,
    this.progressPercent=0.0,
    this.thumbSize=10.0,
    this.thumbColor=Colors.black,
    this.thumbPosition=0.0,
    this.outerPadding=const EdgeInsets.all(0.0),
    this.innerPadding=const EdgeInsets.all(0.0),
    this.child,
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {

  EdgeInsets _insetsForPainter(){
    final outerThickness=max(widget.trackWidth,max(widget.progressWidth,widget.thumbSize))/2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: new CustomPaint(
        foregroundPainter: new RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition
        ),
        child: new Padding(
          padding: _insetsForPainter()+widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter{

  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;
  final double thumbSize;
  final Paint thumbPaint;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required  progressColor,
    @required this.progressPercent,
    @required this.thumbSize,
    @required thumbColor,
    @required this.thumbPosition,
  }):   trackPaint=new Paint()
      ..color=trackColor
      ..style=PaintingStyle.stroke
      ..strokeWidth=trackWidth,
        progressPaint=new Paint()
      ..color=progressColor
      ..style=PaintingStyle.stroke
      ..strokeWidth=progressWidth
      ..strokeCap=StrokeCap.round,
        thumbPaint=new Paint()
      ..color=thumbColor
      ..style=PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {

    final outerThickness=max(trackWidth,max(progressWidth,thumbSize));
    Size constrainedSize=new Size(
      size.width-outerThickness,
      size.height-outerThickness,
    );

    final center=new Offset(size.width/2, size.height/2);
    final radius=min(constrainedSize.width,constrainedSize.height)/2;
    //Paint track
    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    //Paint progress
    final progressAngle=2*pi*progressPercent;
    canvas.drawArc(
      new Rect.fromCircle(center: center,radius: radius),
      -pi/2,
      progressAngle,
      false,
      progressPaint
    );
    
    //Paint thumb
    final thumbAngle=2*pi*thumbPosition-(pi/2);
    final thumbX=cos(thumbAngle)*radius;
    final thumbY=sin(thumbAngle)*radius;
    final thumbRadius=thumbSize/2.0;
    final thumbCenter=new Offset(thumbX,thumbY)+center;
    canvas.drawCircle(
      thumbCenter,
      thumbRadius,
      thumbPaint,
    );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}
