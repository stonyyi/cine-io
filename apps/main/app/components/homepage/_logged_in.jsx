/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  mixins: [Cine.lib('backbone_mixin')],
  componentDidMount: function() {
    this.props.collection.fetch();
  },
  getBackboneObjects: function(){
    return this.props.collection;
  },
  render: function() {
    var listItems = this.props.collection.map(function(model) {
        return (<li key={model.cid}>{model.get('name')}</li>);
      });

    return (
      <ul>
        {listItems}
      </ul>
    );
  }
});
