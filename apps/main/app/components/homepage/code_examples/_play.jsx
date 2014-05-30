/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('homepage/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'PlayCodeBlock',
  propTypes: {
    streamId: React.PropTypes.string.isRequired
  },
  render: function(){
    var code = [
      "var streamId = '"+this.props.streamId+"'"
    , "  , domId = 'player-example';"
    , ""
    , "CineIO.play(streamId, domId);"
    , ""
    , "// We default the example to muted so that"
    , "// you don't get horrible microphone"
    , "// feedback from the publisher while"
    , "// checking out this example."
    ].join('\n');
    return (<CodeHighlighter code={code} language="javascript" />);
  }
});
