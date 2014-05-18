/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('homepage/_new_project'),
  ListItem = Cine.component('homepage/_project_list_item'),
  Projects = Cine.collection('projects');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    collection: React.PropTypes.instanceOf(Projects).isRequired
  },
  componentDidMount: function() {
    this.props.collection.fetch();
  },
  getBackboneObjects: function(){
    return this.props.collection;
  },
  render: function() {

    var listItems = this.props.collection.map(function(model) {
        return (<ListItem key={model.cid} model={model} />);
      });
    return (
      <div>
        <div className="panel">
          <h3> My Projects</h3>
          <ul className="no-bullet">
            {listItems}
          </ul>
        </div>
        <div className="panel">
          <NewProject app={this.props.app} projects={this.props.collection}/>
        </div>
      </div>
    );
  }
});
