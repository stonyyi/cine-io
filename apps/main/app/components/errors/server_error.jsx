/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder');

module.exports = React.createClass({
  displayName: 'ErrorsServerError',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  render: function() {
    return (
      <div id='server-error' className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
            <div className="row">
              <div className="large-12 columns">
                <h1>Server error</h1>
                <p>Sorry we could process this request.</p>
              </div>
            </div>
          </div>
          <Footer />
        </div>
      </div>
    );
  }
});
