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
    this.state.streams.fetch({data: {apiKey: this.props.model.get('apiKey')}});
  },
  getBackboneObjects: function(){
    return [this.state.streams];
  },

  render: function() {
    var listItems = this.state.streams.map(function(model) {
      return (<ListItem key={model.cid} model={model} />);
    });

    return (
      <div>
        <Header app={this.props.app}/>
        <div className="panel">
          <h3>{this.props.model.get('name')}</h3>
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
