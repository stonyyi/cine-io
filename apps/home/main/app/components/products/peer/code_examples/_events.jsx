/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('shared/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'EventsCodeBlock',
  render: function(){
    var code = [
      "CineIOPeer.on('media-added', function(data){"
    , "  var peers = document.findElementById('peers');"
    , "  peers.appendChild(data.videoElement);"
    , "});"
    , ""
    ,  "CineIOPeer.on('media-removed', function(data){"
    , "  data.videoElement.remove();"
    , "});"
    ].join('\n')
    return (
      <div>
        <h4>Code for Event Listeners</h4>
        <CodeHighlighter code={code} language="javascript" />
      </div>
    );
  }
});
