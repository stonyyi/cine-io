/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'PeerClientLIbraries',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>Client libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/peer-js-sdk'>
              <img width='36' height='36' src="//cdn.cine.io/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-peer-android'>
              <img width='36' height='36' src="//cdn.cine.io/images/code-logos/android-logo.png" alt="Android logo" title="The Android SDK" />
            </a>
          </li>

        </ul>
      </div>
    )
  }
});
