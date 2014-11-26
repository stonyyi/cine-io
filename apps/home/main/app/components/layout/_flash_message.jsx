/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'FlashHolder',
  render: function() {
    var alertClasses = [this.props.kind, 'alert-box', 'radius'].join(' '),
    closeAlert;
    if (typeof this.props.closeAlert === 'function'){
      closeAlert = (
        <a href="" className='close-alert' onClick={this.props.closeAlert}>
          <i className="fa fa-times"></i>
        </a>
        )
    }
    return (
      <div data-alert className={alertClasses}>
        <span className='alert-body' dangerouslySetInnerHTML={{__html: this.props.message}} />
        {closeAlert}
      </div>
    );
  }
});
