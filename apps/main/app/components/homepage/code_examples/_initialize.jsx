/** @jsx React.DOM */
var
  React = require('react');
  CodeHighlighter = Cine.component('homepage/code_examples/_code_highlighter');

module.exports = React.createClass({
  displayName: 'InitializeCodeBlock',
  propTypes: {
    publicKey: React.PropTypes.string.isRequired
  },
  render: function(){
    var code = [
      "&lt;script src='https://www.cine.io/compiled/cine.js'&gt;"
    , "&lt;script&gt;"
    , "  CineIO.init('"+this.props.publicKey+"');"
    , "&lt;/script&gt;"
    ].join('\n');
    return (<CodeHighlighter code={code} language="markup" />);
  }
});
