/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'CodeHighlighter',
  propTypes: {
    code: React.PropTypes.string.isRequired,
    language: React.PropTypes.string.isRequired
  },
  componentDidMount: function(){
    this.highlight();
  },
  componentDidUpdate: function(){
    this.highlight();
  },
  highlight: function(){
    Prism.highlightElement(this.refs.theCode.getDOMNode());
  },
  render: function(){
    var language = 'language-'+this.props.language;
    return (
      <pre className={language}>
        <code ref='theCode' className={language} dangerouslySetInnerHTML={{__html: this.props.code }} />
      </pre>
    );
  }
});
