/** @jsx React.DOM */

TodoList = React.createClass({
  render: function() {
    var createItem;
    createItem = function(itemText, index) {
      var key = 'item-' + index;
      return (
        <li key={key}>{itemText}</li>
      );
    };
    return (
      <ul>{this.props.items.map(createItem)}</ul>
      );
  }
});

TodoApp = React.createClass({
  getInitialState: function() {
    return {items: [], text: ''};
  },
  onChange: function(e) {
    return this.setState({text: e.target.value });
  },
  handleSubmit: function(e) {
    var nextItems, nextText;
    e.preventDefault();
    this.state.items.push(this.state.text);
    this.setState({text: '' });
  },
  render: function() {
    var value = this.state.text;
    return (
      <div>
        <h3>TODO</h3>
        <TodoList items={this.state.items} />
        <form onSubmit={this.handleSubmit}>
          <input onChange={this.onChange} value={value}/>
          <button> Add # {this.state.items.length + 1}</button>
        </form>
      </div>
    );
  }
});

React.renderComponent(
  <TodoApp />,
  document.getElementById('todo'));
