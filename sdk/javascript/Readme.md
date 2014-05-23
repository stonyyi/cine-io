# Cine.io JS SDK

## Installation

```html
<script src="https://www.cine.io/compiled/cine.js"></script>
```

## Usage

#### Init

Start off by initializing Cine.io with your public apiKey.

```javascript
CineIO.init(CINE_IO_API_KEY)
```

#### Play

```javascript
CineIO.play(streamId, domId, playOptions)
```

**streamId**

streamId is a Cine.io stream id returned when accessing the create stream endpoint.

**domId**

domId is the ID of the dom node you want the player to be injected into.

**available/default play options are:**

*  stretching: 'uniform'
*  width: '100%'
*  aspectratio: '16:9'
*  primary: 'flash'
*  autostart: true
*  metaData: true
*  rtmp:
   * subscribe: true

#### Publish

```javascript
publisher = CineIO.publish(streamId, streamPassword, domId, publishOptions)
publisher.start() // starts the broadcast
publisher.stop() // stops the broadcast
```

**streamId**

streamId is a Cine.io stream id returned when accessing the create stream endpoint.

**streamPassword**

streamPassword is a Cine.io stream password returned when accessing the create stream endpoint. Only expose the streamPassword to your users who have permission to publish.

**domId**

domId is the ID of the dom node you want the player to be injected into.

**available/default publish options are:**


*  serverURL: null
*  streamName: null
*  streamKey: null
*  audioCodec: 'NellyMoser'
   * available options are 'NellyMoser' and 'Speex'
*  streamWidth: 720
*  streamHeight: 404
*  streamFPS: 15
*  keyFrameInterval: null
*  intervalSecs: 10
*  bandwidth: 1500
*  videoQuality: 90
