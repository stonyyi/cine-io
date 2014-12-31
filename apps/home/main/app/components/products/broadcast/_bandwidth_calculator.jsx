/** @jsx React.DOM */
var
  React = require('react'),
  BandwidthCalculator = Cine.lib('bandwidth_calculator'),
  UsageReport = Cine.model('usage_report'),
  humanizeBytes = Cine.lib('humanize_bytes'),
  capitalize = Cine.lib('capitalize'),
  ProvidersAndPlans = Cine.require('config/providers_and_plans');

var maxSliderScale = 1000
//http://stackoverflow.com/questions/846221/logarithmic-slider
var logScale = function(position, minLogScale, maxLogScale, logBase){
  if (logBase == null){
    logBase = Math.E
  }
  var minp = 1;
  var maxp = maxSliderScale;

  var minv =  Math.log(minLogScale) / Math.log(logBase);
  var maxv =  Math.log(maxLogScale) / Math.log(logBase);

  // calculate adjustment factor
  var scale = (maxv-minv) / (maxp-minp);

  return Math.exp(minv + scale*(position-minp));
}

var linearScale = function(value, scaleMin, scaleMax) {
  var currentPercent, eachStep;
  eachStep = 1 / maxSliderScale;
  // currentPercent is how far along in the scale are we
  // half way is 0.5
  currentPercent = value * eachStep;
  // so we subtract scaleMax from scaleMin
  // and take the percent of that
  // then we add back in scaleMin
  return ((scaleMax - scaleMin) * currentPercent) + scaleMin;
};

// https://support.google.com/youtube/answer/2853702?hl=en
var bitrateFromStep = function(step){
  return [400, 750, 1000, 2500, 4500][step]
}

var exponentScale = function(value, step, max) {
  var currentScaleOnUs, multiplier, totalSteps, returnValue;
  totalSteps = Math.sqrt(max / step, 2) + 1;
  currentScaleOnUs = linearScale(value, 0, totalSteps);
  console.log('currentScaleOnUs', currentScaleOnUs);
  if (currentScaleOnUs > 1) {
    multiplier = Math.pow(2, currentScaleOnUs - 1);
    console.log('multiplier', multiplier);
  } else {
    multiplier = currentScaleOnUs;
  }
  returnValue = 15 * multiplier;
  return returnValue < 1 ? 1 : returnValue;
};

var getStyle = function(currentPostition){
  return {width: ((currentPostition / maxSliderScale) * 100)+"%"};
}

module.exports = React.createClass({
  displayName: 'BandwidthCalculator',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {numberOfViewers: 205, bitRate: 3, videoLength: 400, simultaneousBroadcasts: 205}
  },
  doNothing: function(e){
    e.preventDefault();
  },
  getApiKey: function(plan, value, e){
    e.preventDefault();
    this.props.app.trigger('hide-modal');
    this.props.app.tracker.getApiKey({value: value});
    this.props.app.trigger('set-signup-plan', {broadcast: plan});
    this.props.app.trigger('show-login');
  },
  componentDidMount: function(){
    var self = this;
    $(this.refs.bandwidthCalculator.getDOMNode()).foundation();
    $(this.refs.numberOfViewers.getDOMNode()).on('change.fndtn.slider', function(event){
      self.setState({numberOfViewers: Number($(event.currentTarget).attr('data-slider'))})
    });
    $(this.refs.bitRate.getDOMNode()).on('change.fndtn.slider', function(event){
      self.setState({bitRate: Number($(event.currentTarget).attr('data-slider'))})
    });
    $(this.refs.videoLength.getDOMNode()).on('change.fndtn.slider', function(event){
      self.setState({videoLength: Number($(event.currentTarget).attr('data-slider'))})
    });
    $(this.refs.simultaneousBroadcasts.getDOMNode()).on('change.fndtn.slider', function(event){
      self.setState({simultaneousBroadcasts: Number($(event.currentTarget).attr('data-slider'))})
    });
  },
  render: function() {

    var
      calc = new BandwidthCalculator,
      sliderOptions = "start: 1; end: "+maxSliderScale+";",
      bitRateStyle = getStyle(this.state.bitRate),
      videoLengthStyle = getStyle(this.state.videoLength),
      simultaneousBroadcastsStyle = getStyle(this.state.simultaneousBroadcasts),
      numberOfViewersStyle = getStyle(this.state.numberOfViewers),
      totalBandwidth, cost, humanizedPlan;
    scaleViewers = Math.floor(logScale(this.state.numberOfViewers, 1, 100000));
    scaleVideoLength = Math.floor(exponentScale(this.state.videoLength, 15, 240)); //180.5 leads to floor of 180
    scaleBitRate = bitrateFromStep(this.state.bitRate); //396 leads to 400 on the 1 position
    scaleSimultaneousBroadcasts = Math.floor(logScale(this.state.simultaneousBroadcasts, 1, 100000));

    calc.numberOfViewers = scaleViewers;
    calc.bitRate = scaleBitRate;
    calc.videoLength = scaleVideoLength;
    calc.simultaneousBroadcasts = scaleSimultaneousBroadcasts;
    console.log("Calculator", calc)
    totalBandwidth = calc.calculate();
    bestPlan = UsageReport.lowestPlanPerUsage(totalBandwidth, 'bandwidth', 'broadcast');
    cost = ProvidersAndPlans['cine.io'].plans[bestPlan].price;
    humanizedPlan = capitalize(bestPlan);
    humanizedBandwidth = humanizeBytes(totalBandwidth);
    return (
      <div ref="bandwidthCalculator" className="bandwidth-calculator">
        <h2 className="text-center">Which plan do you need?</h2>
        <div className="row">
          <div className="columns large-6">
            <form onSubmit={this.doNothing}>
              <div><strong># Viewers</strong>: {scaleViewers}</div>
              <div className='row'>
                <div className="small-11 columns">
                  <div className="range-slider radius" ref="numberOfViewers" data-slider={this.state.numberOfViewers} data-options={sliderOptions}>
                    <span className="range-slider-handle"></span>
                    <span className="range-slider-active-segment" style={numberOfViewersStyle}></span>
                  </div>
                </div>
              </div>
              <div className='range-steps'>
                <div className='row'>
                <div className='small-2 columns'>1</div>
                <div className='small-2 columns'>10</div>
                <div className='small-2 columns'>100</div>
                <div className='small-2 columns'>1,000</div>
                <div className='small-2 columns'>10k</div>
                <div className='small-2 columns'>100k</div>
                </div>
              </div>
              <div><strong>Quality</strong>: {scaleBitRate}</div>
              <div className='row'>
                <div className="small-11 columns">
                  <div className="range-slider radius" ref="bitRate" data-slider={this.state.bitRate} data-options="start: 0; end: 4;">
                    <span className="range-slider-handle"></span>
                    <span className="range-slider-active-segment" style={bitRateStyle}></span>
                  </div>
                </div>
              </div>
              <div className='range-steps'>
                <div className='row'>
                  <div className="small-11 columns">
                    <div className='twenty-four-percent left'>240p</div>
                    <div className='twenty-four-percent left'>360p</div>
                    <div className='twenty-four-percent left'>480p</div>
                    <div className='twenty-eight-percent left'>
                      <div className='clearfix'>
                        <div className='left'>720p</div>
                        <div className='right'>1080p</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div><strong>Duration (min)</strong>: {scaleVideoLength}</div>
              <div className='row'>
                <div className="small-11 columns">
                  <div className="range-slider radius" ref="videoLength" data-slider={this.state.videoLength} data-options={sliderOptions}>
                    <span className="range-slider-handle"></span>
                    <span className="range-slider-active-segment" style={videoLengthStyle}></span>
                  </div>
                </div>
              </div>
              <div className='range-steps'>
                <div className='row'>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">1 min</span>
                  <span className="show-for-medium-up">1 minute</span>
                </div>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">15 min</span>
                  <span className="show-for-medium-up">15 minutes</span>
                </div>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">30 min</span>
                  <span className="show-for-medium-up">30 minutes</span>
                </div>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">1 hr</span>
                  <span className="show-for-medium-up">1 hour</span>
                </div>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">2 hr</span>
                  <span className="show-for-medium-up">2 hours</span>
                </div>
                <div className='small-2 columns'>
                  <span className="show-for-small-only">3 hr</span>
                  <span className="show-for-medium-up">3 hours</span>
                </div>
                </div>
              </div>
              <div><strong># Broadcasts</strong>: {scaleSimultaneousBroadcasts}</div>
              <div className='row'>
                <div className="small-11 columns">
                  <div className="range-slider radius" ref="simultaneousBroadcasts" data-slider={this.state.simultaneousBroadcasts} data-options={sliderOptions}>
                    <span className="range-slider-handle"></span>
                    <span className="range-slider-active-segment" style={simultaneousBroadcastsStyle}></span>
                  </div>
                </div>
              </div>
              <div className='range-steps'>
                <div className='row'>
                <div className='small-2 columns'>1</div>
                <div className='small-2 columns'>10</div>
                <div className='small-2 columns'>100</div>
                <div className='small-2 columns'>1,000</div>
                <div className='small-2 columns'>10k</div>
                <div className='small-2 columns'>100k</div>
                </div>
              </div>
            </form>
          </div>
          <div className="columns large-6">
            <div className="row">
              <div className="columns small-8 small-offset-2">
                <ul className="pricing-table top-margin-1">
                  <li className="title">{humanizedPlan}</li>
                  <li className="price">
                    <span className="currency">$</span>
                    <span className="amount">{cost} / mo</span>
                  </li>
                  <li className="cta-button">
                    <a className="button radius" href="" onClick={this.getApiKey.bind(this, bestPlan, 5)}>Get Started</a>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
