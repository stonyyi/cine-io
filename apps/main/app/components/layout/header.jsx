/** @jsx React.DOM */
var React = require('react')
  , LoggedIn = Cine.component('layout/_logged_in')
  , LoggedOut = Cine.component('layout/_logged_out')
  , cx = Cine.lib('cx')
  , Brand = Cine.component('layout/_brand');

module.exports = React.createClass({
  displayName: 'Header',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getInitialState: function(){
    return {expanded: false};
  },
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  toggleExpandMenu: function(e){
    e.preventDefault();
    this.setState({expanded: !this.state.expanded});
  },
  render: function() {
    var topBarClasses = cx({
      "top-bar": true,
      "expanded": this.state.expanded
    });

    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <header>
          <nav className={topBarClasses}>
            <Brand app={this.props.app} toggleExpandMenu={this.toggleExpandMenu}/>
            <LoggedIn app={this.props.app} />
          </nav>
        </header>
      );
    } else {
      return (
        <header>
          <nav className={topBarClasses}>
            <Brand app={this.props.app} toggleExpandMenu={this.toggleExpandMenu}/>
            <LoggedOut app={this.props.app} />
          </nav>
        </header>
      );
    }
  }
});
