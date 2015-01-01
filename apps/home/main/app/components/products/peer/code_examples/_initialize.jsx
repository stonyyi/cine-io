/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('shared/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'InitializeCodeBlock',
  propTypes: {
    publicKey: React.PropTypes.string.isRequired
  },
  render: function(){
    var code = [
      "&lt;script src='//cdn.cine.io/cineio-peer.js'&gt;"
    , "&lt;script&gt;"
    , "  CineIOPeer.init('"+this.props.publicKey+"');"
    , "&lt;/script&gt;"
    ].join('\n');
    return (
      <div>
        <h4>Code for Initialization</h4>
        <CodeHighlighter code={code} language="markup" />
      </div>
    );
  }
});
