csv = require("csv")
fs = require("fs")
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
EdgecastStream = Cine.server_model('edgecast_stream')
path = require('path')
_ = require('underscore')
outPath = "/dev/null"
streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')

edgecastStreamReportByInstanceNameAndStreamName = (streamName, callback)->
  query = streamName: streamName
  EdgecastStream.findOne query, (err, stream)->
    return callback(err) if err
    return callback("could not find stream: #{streamName}") if !stream
    EdgecastStreamReport.findOne _edgecastStream: stream._id, (err, esr)->
      return callback(err) if err
      return callback null, esr if esr
      return callback null, new EdgecastStreamReport _edgecastStream: stream._id

# data =
#   bytes, entryDate, duration
saveDataOnRecord = (streamName, entryData, callback)->
  edgecastStreamReportByInstanceNameAndStreamName streamName, (err, esr)->
    if err
      console.log(err, entryData)
      return callback(err)
    esr.logEntries.push entryData
    esr.save callback

module.exports = (absoluteFileName, done)->
  console.log('parsing', absoluteFileName)
  errs = []

  errorFunction = (err)->
    console.error("ERROR", err)
    done(err)

  closeFunction = (count) ->
    console.log "Number of lines: " + count
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

    streamName = streamRecordingNameEnforcer.extractStreamNameFromHlsFile(data['cs-uri-stem'])
    entryData =
      bytes: Number(data['sc-bytes'])
      entryDate: new Date "#{data.date} #{data.time}"
      kind: 'hls'
    saveDataOnRecord streamName, entryData, (err)->
      # console.log('saved', err)
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
###
