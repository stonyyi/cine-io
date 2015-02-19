debug = require('debug')('cine:parse_edgecast_log')
csv = require("csv")
fs = require("fs")
StreamUsageReport = Cine.server_model('stream_usage_report')
EdgecastStream = Cine.server_model('edgecast_stream')
path = require('path')
_ = require('underscore')
outPath = "/dev/null"

# rtmp://fml.C45E.edgecastcdn.net/20C45E/stages/ -> stages
convertUriStemToInstanceName = (uriStem)->
  parts = uriStem.split('/')
  parts[parts.length-2]

edgecastStreamReportByInstanceNameAndStreamName = (instanceName, streamName, callback)->
  query = instanceName: instanceName, streamName: streamName
  EdgecastStream.findOne query, (err, stream)->
    return callback(err) if err
    return callback("could not find stream: #{instanceName}, #{streamName}") if !stream
    StreamUsageReport.findOne _edgecastStream: stream._id, (err, esr)->
      return callback(err) if err
      return callback null, esr if esr
      return callback null, new StreamUsageReport _edgecastStream: stream._id

isInvalidInstanceName = (instanceName)->
  instanceName == '20C45E'

# data =
#   bytes, entryDate, duration
saveDataOnRecord = (instanceName, streamName, entryData, callback)->
  return callback() if isInvalidInstanceName(instanceName)
  edgecastStreamReportByInstanceNameAndStreamName instanceName, streamName, (err, esr)->
    if err
      debug(err, entryData)
      return callback(err)
    esr.logEntries.push entryData
    esr.save callback


# http://hls.cine.io/23C45E/stages/stage45/stage45Num3.ts
convertCReferrerToInstanceAndStream = (cReferrer)->
  parts = cReferrer.split('/')
  instance = parts[parts.length-3]
  stream = parts[parts.length-2]
  {instanceName: instance, streamName: stream}


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


  processFMSRecord = (data, rowNumber, callback)->
    return callback() unless data['#Fields: x-event'] == 'stop'
    instanceName = convertUriStemToInstanceName(data['cs-uri-stem'])
    streamName = data['x-sname']
    entryData =
      bytes: Number(data['sc-bytes'])
      entryDate: new Date "#{data.date} #{data.time}"
      duration: Number data['x-duration']
      kind: 'fms'
    saveDataOnRecord instanceName, streamName, entryData, (err)->
      debug('saved', err)
      errs.push(data: data, rowNumber: rowNumber, error: err) if err
      callback()

  headers = null
  processWPCRecord = (rowData, rowNumber, callback)->
    # headers starts with annoying "Fields: ", remove that
    if rowNumber == 0
      headers = rowData.slice(1, rowData.length - 1)
      return callback()
    # turn rowData from an array into object with "headers" as keys
    data = _.object(headers, rowData)
    # extract instance/stream from cine.io hls url
    streamData = convertCReferrerToInstanceAndStream(data['cs-uri-stem'])
    entryData =
      bytes: Number(data['sc-bytes'])
      entryDate: new Date(Number(data.timestamp) * 1000)
      kind: 'hls'
    # there's a lot of chatter around 500 bytes,
    # I don't think this is part of the "streaming" protocol
    # I think this is more "handshake" stuff.
    # Most of the log entries are either 500 bytes or 2-4 mb.
    # just save the mb calls, which I imagine is the actual streaming.
    return callback() unless entryData.bytes > 1000
    # debug(data['sc-status'], entryData.bytes, data['rs-bytes'])
    # callback()
    saveDataOnRecord streamData.instanceName, streamData.streamName, entryData, (err)->
      errs.push(data: data, rowNumber: rowNumber, error: err) if err
      callback()

  switch path.basename(absoluteFileName).slice(0,3)
    when 'fms'
      inOpts =
        delimiter: "\t"
        columns: true
      processRecord = processFMSRecord
    when 'wpc'
      inOpts =
        delimiter: " "
      processRecord = processWPCRecord
    else
      done("UNKNOWN FILE TYPE")

  csv().from.path(absoluteFileName, inOpts)
    .to.stream(fs.createWriteStream(outPath))
    .transform(processRecord, parallel: 1)
    .once("close", closeFunction)
    .on("error", errorFunction)


###
WPC looks like:
{ timestamp: '1400396107',
  'time-taken': '284',
  'c-ip': '50.184.110.201',
  filesize: '2256376',
  's-ip': '46.22.78.218',
  's-port': '80',
  'sc-status': 'TCP_EXPIRED_MISS/200',
  'sc-bytes': '2256659',
  'cs-method': 'GET',
  'cs-uri-stem': 'http://hls.cine.io/23C45E/stages/stage45/stage45Num14.ts',
  '-': '-',
  'rs-duration': '316',
  'rs-bytes': '2257079',
  'c-referrer': 'http://hls.cine.io/stages/stage45/stage45.m3u8',
  'c-user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14',
  'customer-id': '50270' }

FMS looks like:
{ '#Fields: x-event': 'stop',
  'x-category': 'stream',
  date: '2014-05-14',
  time: '04:17:00',
  'x-duration': '26',
  'x-status': '408',
  'c-ip': '76.14.69.171',
  's-ip': '46.22.78.87',
  'c-proto': 'rtmp',
  'cs-uri-stem': 'rtmp://fml.C45E.edgecastcdn.net/20C45E/stages/',
  'cs-uri-query': '-',
  'c-referrer': 'https://ssl.p.jwpcdn.com/6/8/jwplayer.flash.swf',
  'c-user-agent': 'MAC 13,0,0,206',
  'cs-bytes': '3207',
  'sc-bytes': '3965',
  'x-file-size': '-',
  'x-file-length': '-',
  'x-sname': 'stage29',
  'x-file-name': '-',
  'x-file-ext': 'flv',
  'x-app': '20C45E',
  'sc-stream-bytes': '330',
  'c-client-id': '4702151916220662129',
  'x-sid': '1',
  'x-comment': '-\r' }
###
