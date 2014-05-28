/** @jsx React.DOM */
var
  React = require('react'),
  Project = Cine.model('project'),
  Stream = Cine.model('stream'),
  Streams = Cine.collection('streams');

module.exports = React.createClass({
  displayName: 'NewStream',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    project: React.PropTypes.instanceOf(Project).isRequired,
    streams: React.PropTypes.instanceOf(Streams).isRequired
  },
  createStream: function (e) {
    e.preventDefault();
    var self = this,
      p = new Stream({secretKey: this.props.project.get('secretKey')}, {app: this.props.app});
    p.save(null, {
      success: function(model, response, options){
        self.props.streams.add(model);
        self.props.project.set('streamsCount', self.props.project.get('streamsCount') + 1);
      }
    });
  },
  render: function() {
    return (
      <form onSubmit={this.createStream}>
        <button type='submit'> Create Stream </button>
      </form>
    );
  }
});
