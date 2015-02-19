debug = require('debug')('cine:parse_cloudfront_log')
csv = require("csv")
fs = require("fs")
StreamUsageReport = Cine.server_model('stream_usage_report')
EdgecastStream = Cine.server_model('edgecast_stream')
path = require('path')
_ = require('underscore')
_str = require('underscore.string')
outPath = "/dev/null"
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')

edgecastStreamReportByInstanceNameAndStreamName = (streamName, callback)->
  query = streamName: streamName
  EdgecastStream.findOne query, (err, stream)->
    return callback(err) if err
    return callback("could not find stream: #{streamName}") if !stream
    StreamUsageReport.findOne _edgecastStream: stream._id, (err, esr)->
      return callback(err) if err
      return callback null, esr if esr
      return callback null, new StreamUsageReport _edgecastStream: stream._id

# data =
#   bytes, entryDate, duration
saveDataOnRecord = (streamName, entryData, callback)->
  edgecastStreamReportByInstanceNameAndStreamName streamName, (err, esr)->
    if err
      debug(err, entryData)
      return callback(err)
    esr.logEntries.push entryData
    esr.save callback

module.exports = (absoluteFileName, done)->
  debug('parsing', absoluteFileName)
  errs = []

  errorFunction = (err)->
    console.error("ERROR", err)
    done(err)

  closeFunction = (count) ->
    debug "Number of lines: " + count
    return done(errs) if errs.length > 0
    done()

  headers = null
  processLogRow = (rowData, rowNumber, callback)->
    return callback() if rowNumber == 0
    if rowNumber == 1
      headerSplit = rowData[0].split(" ")
      headers = headerSplit.slice(1, headerSplit.length - 1)
      return callback()
    data = _.object(headers, rowData)
    uri = data['cs-uri-stem']
    if _str.endsWith(uri, '.ts')
      streamName = streamRecordingNameEnforcer.extractStreamNameFromHlsFile(uri)
      entryData =
        bytes: Number(data['sc-bytes'])
        entryDate: new Date "#{data.date} #{data.time}"
        kind: 'hls'
    else if _str.endsWith(uri, '.mp4')
      streamName = streamRecordingNameEnforcer.extractStreamNameFromDirectory(uri)
      entryData =
        bytes: Number(data['sc-bytes'])
        entryDate: new Date "#{data.date} #{data.time}"
        kind: 'vod'
    else
      errs.push(data: data, rowNumber: rowNumber, error: "unknown uri")
      return callback()
    saveDataOnRecord streamName, entryData, (err)->
      # debug('saved', err)
      errs.push(data: data, rowNumber: rowNumber, error: err) if err
      callback()

  inOpts =
    delimiter: "\t"

  csv().from.path(absoluteFileName, inOpts)
    .to.stream(fs.createWriteStream(outPath))
    .transform(processLogRow, parallel: 1)
    .once("close", closeFunction)
    .on("error", errorFunction)


###
HLS looks like:
{
  date: '2014-11-24',
  time: '19:26:41',
  'x-edge-location': 'SFO5',
  'sc-bytes': '682919',
  'c-ip': '24.18.84.223',
  'cs-method': 'GET',
  'cs(Host)': 'diibtb4zn1vsj.cloudfront.net',
  'cs-uri-stem': '/hls/bkcFcqG0V-1416857189159.ts',
  'sc-status': '206',
  'cs(Referer)': '-',
  'cs(User-Agent)': 'VLC/2.1.5%2520LibVLC/2.1.5',
  'cs-uri-query': '-',
  'cs(Cookie)': '-',
  'x-edge-result-type': 'Miss',
  'x-edge-request-id': 'Zgq03gi0REjMo6ymaRjkpsTXv7mXgJakMyNlExxPcCaxgp-_r3Od4g==',
  'x-host-header': 'diibtb4zn1vsj.cloudfront.net',
  'cs-protocol': 'http',
  'cs-bytes': '173'
}

VOD looks like:
{
  date: '2014-11-24',
  time: '01:48:56',
  'x-edge-location': 'SFO5',
  'sc-bytes': '1627099',
  'c-ip': '24.18.84.223',
  'cs-method': 'GET',
  'cs(Host)': 'd16tzlai5ag6m5.cloudfront.net',
  'cs-uri-stem': '/cines/980cf5c2b95fe3b181645b4e4256a0bb/bkcFcqG0V.20141124T013843.mp4',
  'sc-status': '206',
  'cs(Referer)': 'http://vod.cine.io/cines/980cf5c2b95fe3b181645b4e4256a0bb/bkcFcqG0V.20141124T013843.mp4',
  'cs(User-Agent)': 'Mozilla/5.0%2520(Macintosh;%2520Intel%2520Mac%2520OS%2520X%252010_10_1)%2520AppleWebKit/537.36%2520(KHTML,%2520like%2520Gecko)%2520Chrome/38.0.2125.122%2520Safari/537.36',
  'cs-uri-query': '-',
  'cs(Cookie)': '-',
  'x-edge-result-type': 'Error',
  'x-edge-request-id': 'M3Xh_mIm6NoEYNVjpQ_KhZB0Ni0ylFmB3p3w-yyjQJYfY6DphNN12g==',
  'x-host-header': 'vod.cine.io',
  'cs-protocol': 'http',
  'cs-bytes': '821'
}
###
