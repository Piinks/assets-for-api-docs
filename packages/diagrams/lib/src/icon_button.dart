// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'dropdown_button.dart';

final Duration _kTotalDuration = _kPauseDuration * 5;
const Duration _kPauseDuration = Duration(seconds: 1);
const double _kAnimationFrameRate = 60.0;

final GlobalKey _muteKey = new GlobalKey();
final GlobalKey _upKey = new GlobalKey();
final GlobalKey _downKey = new GlobalKey();

class IconButtonDiagram extends StatefulWidget
  implements DiagramMetadata {
  const IconButtonDiagram(this.name);

  @override
  final String name;

  @override
  State<IconButtonDiagram> createState() => IconButtonDiagramState();
}

class IconButtonDiagramState extends State<IconButtonDiagram> {

  double _volume = 0.0;
  bool _isDisabled = true;

  void _decreaseVolume() {
    setState(() {
      _volume -= 10;
      if(_volume == 0) {
        _isDisabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(350.0, 400.0)),
      child: Navigator(onGenerateRoute: (RouteSettings s) {
      return NoAnimationMaterialPageRoute<void>(builder: (BuildContext context) {
    return new ConstrainedBox(
            key: new UniqueKey(),
            constraints: new BoxConstraints.tight(const Size(400.0, 150.0)),
            child: new Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.all(10.0),
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          key: _muteKey,
                          icon: const Icon(Icons.volume_off),
                          tooltip: 'Mute Volume',
                          iconSize: 35,
                          splashColor: Colors.red,
                          onPressed: () {
                            setState(() {
                              _volume = 0;
                              _isDisabled = true;
                            });
                          },
                        ),
                        IconButton(
                          key: _downKey,
                          icon: const Icon(Icons.volume_down),
                          tooltip: 'Decrease volume by 10',
                          iconSize: 35,
                          splashColor: Colors.purple[100],
                          onPressed: _isDisabled ? null : _decreaseVolume,
                        ),
                        IconButton(
                          key: _upKey,
                          icon: const Icon(Icons.volume_up),
                          tooltip: 'Increase volume by 10',
                          iconSize: 35,

                          splashColor: Colors.purple[700],
                          onPressed: () {
                            setState(() {
                              _volume += 10;
                              _isDisabled = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text('Volume : $_volume', style: Theme
                      .of(context)
                      .textTheme
                      .subhead),
                  ],
                ),
              ),
            ),
    );
      });
      }),
    );
  }
}

class IconButtonDiagramStep extends DiagramStep {
  IconButtonDiagramStep(DiagramController controller)
    : super(controller);

  void tapButtons(DiagramController controller, Duration now) async {
    //print(now.inMilliseconds);
    // 1000 up
    // 2000 up
    // 3100 down
    // 4100 mute
    RenderBox target;
    switch (now.inMilliseconds) {
      case 1000:
        target = _upKey.currentContext.findRenderObject();
        break;
      case 2000:
        target = _upKey.currentContext.findRenderObject();
        break;
      case 3100:
        target = _downKey.currentContext.findRenderObject();
        break;
      case 4100:
        target = _muteKey.currentContext.findRenderObject();
        break;
      default:
        return;
    }
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    gesture.up();
  }

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const IconButtonDiagram('icon_button'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final IconButtonDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      gestureCallback: tapButtons,
    );
//    gesture.up();
//    return result;
  }
}
