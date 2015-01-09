/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'BroadcastMobileApps',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>Mobile apps</h4>
        <a target="_blank" href='https://itunes.apple.com/us/app/cine.io-console/id900579145'>
          <img className='bottom-margin-1' width='135' height='40' src="//cdn.cine.io/images/app-store-badge-135x40.svg" alt="App Store Badge" title="cine.io Console app" />
        </a>
      </div>
    )
  }
});
