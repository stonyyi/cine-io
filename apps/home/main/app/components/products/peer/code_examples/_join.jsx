/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('shared/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'JoinCodeBlock',
  propTypes: {
    room: React.PropTypes.string.isRequired,
  },
  render: function(){
    var code = [
      "var room = '"+this.props.room+"';"
    , ""
    , "CineIOPeer.startCameraAndMicrophone();"
    , ""
    , "CineIOPeer.join(room);"
    ].join('\n')
    return (
      <div>
        <h4>Code for starting a chat in a room</h4>
        <CodeHighlighter code={code} language="javascript" />
      </div>
    );
  }
});
