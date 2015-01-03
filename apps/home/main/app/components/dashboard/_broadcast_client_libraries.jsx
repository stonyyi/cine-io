/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'BroadcastClientLibraries',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>Client libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/js-sdk'>
              <img width='36' height='36' src="/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-broadcast-ios'>
              <img width='36' height='36' src="/images/code-logos/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-broadcast-android'>
              <img width='36' height='36' src="/images/code-logos/android-logo.png" alt="Android logo" title="The Android SDK" />
            </a>
          </li>
        </ul>

      </div>
    )
  }
});
