/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder');

module.exports = React.createClass({
  displayName: 'ErrorsUnauthorized',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  showSignIn: function(e){
    e.preventDefault();
    this.props.app.trigger('show-login');
  },

  render: function() {
    return (
      <div id='unauthorized' className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
            <div className="row">
              <div className="large-12 columns">
                <h1>Unauthorized</h1>
                <p>Please <a href="" onClick={this.showSignIn}> log in</a> to access this resource.</p>
              </div>
            </div>
          </div>
          <Footer />
        </div>
      </div>
    );
  }
});
