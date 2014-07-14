/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
AccountForm = Cine.component('account/_account_form'),
FlashHolder = Cine.component('layout/flash_holder');

module.exports = React.createClass({
  displayName: 'AccountEdit',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <div id='legal'className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
            <div className="row">
              <dl className="columns large-12">
                <dt>Master Key</dt>
                <dd>{this.props.app.currentUser.get('masterKey')}</dd>
              </dl>
            </div>
            <AccountForm app={this.props.app}/>
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
