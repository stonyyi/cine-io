/** @jsx React.DOM */
var React = require('react'),
BroadcastProduct = Cine.component('products/_broadcast'),
PeerProduct = Cine.component('products/_peer');
WebrtcBroadcast = Cine.component('products/_webrtc_broadcast');

module.exports = React.createClass({
  displayName: 'ProductsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('redirect_to_dashboard_on_login')],
  render: function() {
    var Product;
    if (this.props.options.product === 'broadcast')
      Product = BroadcastProduct;
    else if (this.props.options.product === 'peer')
      Product = PeerProduct;
    else if (this.props.options.product === 'webrtc-broadcast')
      Product = WebrtcBroadcast;
    else
      throw new Error("unknown product")
    return (
      <Product app={this.props.app} />
    );
  }
});
