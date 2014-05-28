/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
Project = Cine.model('project'),
Streams = Cine.collection('streams'),
ListItem = Cine.component('projects/_stream_list_item'),
NewStream = Cine.component('projects/_new_stream');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired
  },
  getInitialState: function(){
    return{
      streams: new Streams([], {app: this.props.app})
    };
  },
  componentDidMount: function() {
    this.state.streams.fetch({data: {secretKey: this.props.model.get('secretKey')}});
  },
  getBackboneObjects: function(){
    return [this.state.streams];
  },

  render: function() {
    var listItems = this.state.streams.map(function(model) {
      return (<ListItem key={model.cid} model={model} />);
    });
    var
      streamsCount = this.props.model.get('streamsCount'),
      streamsWord = streamsCount === 1 ? 'stream' : 'streams';
    return (
      <div>
        <Header app={this.props.app}/>
        <div className="panel">
          <h3>
            <div className='clearfix'>
              <div className='left'>
                {this.props.model.get('name')}
              </div>
              <div className='right'>
                <span> {streamsCount} {streamsWord}</span> /
                <span> {this.props.model.get('plan')} plan</span>
              </div>
            </div>
          </h3>
          <ul className="no-bullet">
            {listItems}
          </ul>
        </div>
        <div className="panel">
          <NewStream app={this.props.app} streams={this.state.streams} project={this.props.model}/>
        </div>
        <Footer />
      </div>
    );
  }
});
