/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder'),
humanizeBytes = Cine.lib('humanize_bytes');

module.exports = React.createClass({
  displayName: 'PasswordChangeRequestsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    var accountLimit = this.props.model.constructor.maxUsagePerAccount(this.props.app.currentUser),
      monthlyBytes = this.props.model.get('monthlyBytes')
    return (
      <div className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className='row'>
            <div className='small-12 columns'>
              <h1>Usage Report</h1>
              <p>{humanizeBytes(monthlyBytes)} of {humanizeBytes(accountLimit)}</p>
            </div>
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
