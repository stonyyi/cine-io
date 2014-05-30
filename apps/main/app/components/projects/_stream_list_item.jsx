/** @jsx React.DOM */
var
  React = require('react'),
  Stream = Cine.model('stream');

module.exports = React.createClass({
  displayName: 'StreamListItem',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Stream).isRequired
  },

  getBackboneObjects: function(){
    return this.props.model;
  },

  deleteProject: function (e) {
    e.preventDefault();
    alert('Not implemented');
  },
  render: function() {
    var model = this.props.model;
    return (
      <tr>
        <td>{model.id}</td>
        <td>{model.get('password')}</td>
      </tr>
    );
  }
});
