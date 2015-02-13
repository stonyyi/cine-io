/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('shared/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'PublishCodeBlock',
  propTypes: {
    streamId: React.PropTypes.string.isRequired,
    password: React.PropTypes.string.isRequired
  },
  render: function(){
    var code = [
      "var streamId = '"+this.props.streamId+"'"
    , "  , password = '"+this.props.password+"';"
    , ""
    , "function callback(err){ console.log(\"started\") };"
    , ""
    , "CineIOPeer.startCameraAndMicrophone();"
    , ""
    , "CineIOPeer.broadcastCameraAndMicrophone("
    , "  streamId, password, callback);"
    ].join('\n')
    return (
      <div>
        <h4>Code for broadcasting your native webcam</h4>
        <CodeHighlighter code={code} language="javascript" />
      </div>
    );
  }
});
