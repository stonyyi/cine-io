/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'BroadcastDocumentation',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>
          <a target="_blank" href='http://developer.cine.io'>Full documentation</a>
        </h4>
        <h4 className='top-margin-1'>Client libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/js-sdk'>
              <img width='36' height='36' src="/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-ios'>
              <img width='36' height='36' src="/images/code-logos/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-android'>
              <img width='36' height='36' src="/images/code-logos/android-logo.png" alt="Android logo" title="The Android SDK" />
            </a>
          </li>
        </ul>

        <h4 className='top-margin-1'>Server side libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
              <img width='36' height='36' src="/images/code-logos/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-python'>
              <img width='36' height='36' src="/images/code-logos/python-logo.png" alt="Python logo" title="The Python Egg" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-node'>
              <img width='36' height='36' src="/images/code-logos/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
            </a>
          </li>
        </ul>

        <h4 className='top-margin-1'>Mobile apps</h4>
        <a target="_blank" href='https://itunes.apple.com/us/app/cine.io-console/id900579145'>
          <img className='bottom-margin-1' width='135' height='40' src="/images/app-store-badge-135x40.svg" alt="App Store Badge" title="cine.io Console app" />
        </a>
      </div>
    )
  }
});
