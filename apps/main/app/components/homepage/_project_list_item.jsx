/** @jsx React.DOM */
var
  React = require('react')
  , Project = Cine.model('project')
  , cx = Cine.lib('cx');
module.exports = React.createClass({
  displayName: 'ProjectListItem',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  accessSettings: function (e) {
    e.preventDefault();
    e.stopPropagation();
    alert('Settings not implemented');
  },
  showStreams: function(e){
    this._owner.selectProject(this.props.model);
  },
  toggleSecretKey: function (e) {
    e.preventDefault();
    this.setState({showApiKey: !this.state.showApiKey});
  },
  render: function() {
    var model = this.props.model
      , classes = cx({selected: this.props.selected})
    ;

    return (
      <tr onClick={this.showStreams} className={classes}>
        <td> {model.get('name')} </td>
        <td>
          <a href='' onClick={this.accessSettings}>
            <i className="fa fa-cogs fa-2x"></i>
          </a>
        </td>
      </tr>
    );
  }
});
