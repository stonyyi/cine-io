/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('homepage/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'PublishCodeBlock',
  propTypes: {
    streamId: React.PropTypes.string.isRequired,
    password: React.PropTypes.string.isRequired
  },
  render: function(){
    var code = [
      "var streamId = '"+this.props.streamId+"'"
    , "  , password = '"+this.props.password+"'"
    , ", domId = 'publisher-example';"
    , ""
    , "var publisher = CineIO.publish("
    , "  streamId, password, domId"
    , ");"
    , ""
    , "publisher.start();"
    ].join('\n')
    return (<CodeHighlighter code={code} language="javascript" />);
  }
});
