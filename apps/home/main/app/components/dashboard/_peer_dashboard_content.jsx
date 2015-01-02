/** @jsx React.DOM */
var
  React = require('react'),
  Project = Cine.model('project'),
  InitializeCodeExample = Cine.component('products/peer/code_examples/_initialize'),
  EventsCodeExample = Cine.component('products/peer/code_examples/_events'),
  JoinCodeExample = Cine.component('products/peer/code_examples/_join');

module.exports = React.createClass({
  displayName: 'PeerDashboardContent',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired,
  },
  getInitialState: function() {
    return {
      room: 'homepage-room',
    };
  },
  getBackboneObjects: function(){
    return [this.props.model];
  },
  render: function(){
    var
      publicKey = this.props.model.get('publicKey'),
      exampleRoom = "example-"+this.props.model.get('name') + "-room";
    return (
      <div className="peer-dashboard-content">
        <div className='row'>
          <div className='medium-12 columns'>
            <InitializeCodeExample publicKey={publicKey} />
          </div>
        </div>
        <div className='row'>
          <div className='medium-6 columns'>
            <EventsCodeExample />
          </div>
          <div className='medium-6 columns'>
            <JoinCodeExample room={exampleRoom}/>
          </div>
        </div>
      </div>
    );
  }
});
