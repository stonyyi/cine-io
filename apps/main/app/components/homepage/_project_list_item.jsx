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
  getInitialState: function(){
    return {showingSettings: false};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  accessSettings: function (e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({showingSettings: !this.state.showingSettings});
  },
  showStreams: function(e){
    this._owner.selectProject(this.props.model);
  },
  deleteProject: function(e){
    e.preventDefault();
    this.props.model.destroy({
      data: {
        secretKey: this.props.model.get('secretKey')
      },
      processData: true,
      wait: true
    });
  },
  render: function() {
    var model = this.props.model,
      classes = cx({selected: this.props.selected}),
      settings = '';

    if (this.state.showingSettings){
      settings = (
        <div>
          <dl>
            <dt>Public key</dt>
            <dd>{model.get('publicKey')}</dd>
            <dt>Secret key</dt>
            <dd>{model.get('secretKey')}</dd>
            <dt>Streams count</dt>
            <dd>{model.get('streamsCount')}</dd>
          </dl>
          <button className='button alert tiny' onClick={this.deleteProject}>Delete {model.get('name')}</button>
        </div>
      );
    }
    return (
      <tr onClick={this.showStreams} className={classes}>
        <td className='no-move'>
          <div>{model.get('name')}</div>
          {settings}
        </td>
        <td className='place-top'>
          <a href='' onClick={this.accessSettings}>
            <i className="fa fa-cogs fa-2x"></i>
          </a>
        </td>
      </tr>
    );
  }
});
