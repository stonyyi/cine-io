/** @jsx React.DOM */
var LikeButton = React.createClass({
  getInitialState: function() {
    return {clicked: false};
  },
  handleClick: function(event) {
    this.setState({clicked: !this.state.clicked});
  },
  render: function() {
    var text = this.state.clicked ? 'clicked' : 'have not clicked';
    return (
      <p onClick={this.handleClick}>
        You {text} this. Click to toggle.
      </p>
    );
  }
});

React.renderComponent(
  <LikeButton />,
  document.getElementById('liker')
);
