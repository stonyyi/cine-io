/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
Static = Cine.component('legal/_static');

module.exports = React.createClass({
  displayName: 'LegalShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],

  getInitialState: function(){
    return{};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    var slug = this.props.model.id.split('/')[1]
      , classNames = {
          "terms-of-service" : ""
        , "privacy-policy" : ""
        , "copyright-claims" : ""
        };
    classNames[slug] = "active";

    return (
      <div id='legal'>
        <Header app={this.props.app} />
        <div className="container">
          <dl className="sub-nav">
            <dd className={classNames['terms-of-service']}><a href="/legal/terms-of-service">Terms of Service</a></dd>
            <dd className={classNames['privacy-policy']}><a href="/legal/privacy-policy">Privacy Policy</a></dd>
            <dd className={classNames['copyright-claims']}><a href="/legal/copyright-claims">Copyright Claims</a></dd>
          </dl>
          <Static document={this.props.model.get('document')} />
        </div>
        <Footer />
      </div>
    );
  }
});
