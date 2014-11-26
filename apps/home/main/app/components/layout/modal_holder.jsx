/** @jsx React.DOM */

var React = require('react');

module.exports = React.createClass({
  displayName: 'ModalHolder',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_modal')],
  showMyModal: function(e){
    e.preventDefault();
    this.props.app.trigger('show-modal', 'homepage/_bandwidth_calculator');
  },
  render: function(){
    if (this.state.showingModal){
      var ModalCompnent = Cine.component(this.state.modalCompnent)
      return (
        <div>
          <div key="modal-bg" className="reveal-modal-bg" />
          <div key="modal-body" className="reveal-modal open">
            <a href="" className="close-reveal-modal" onClick={this.hideModal}><i className="fa fa-times"/></a>
            <ModalCompnent app={this.props.app} />
          </div>
        </div>)
    }else{
      return (<div/>)
    }
  }
});
