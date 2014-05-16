/** @jsx React.DOM */

Timer = React.createClass({
  getInitialState: function() {
    return {secondsElapsed: 0 };
  },
  tick: function() {
    this.setState({
      secondsElapsed: this.state.secondsElapsed + 1
    });
  },
  componentDidMount: function() {
    return setInterval(this.tick, 1000);
  },
  render: function() {
    var seconds = this.state.secondsElapsed;
    return (
      <div> Seconds Elapsed: {seconds} </div>
    );
  }
});

React.renderComponent(
  <Timer />,
  document.getElementById('timer')
);
