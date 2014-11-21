module.exports = ->
  nock('https://cine-io-hls2.s3.amazonaws.com:443')
    .post('/?delete', "<Delete xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Object><Key></Key></Object></Delete>")
    .reply(404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error><Code>NoSuchBucket</Code><Message>The specified bucket does not exist</Message><BucketName>cine-io-hls2</BucketName><RequestId>2B25B2460026FD10</RequestId><HostId>/Y0fpTP/Wi/385plIYnS5gZu/LiO+nt1NHHdOfjE/89xT2Ek5EO5lcWEzV11rKyk</HostId></Error>", { 'x-amz-request-id': '2B25B2460026FD10',
    'x-amz-id-2': '/Y0fpTP/Wi/385plIYnS5gZu/LiO+nt1NHHdOfjE/89xT2Ek5EO5lcWEzV11rKyk',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    date: 'Fri, 21 Nov 2014 21:38:58 GMT',
    connection: 'close',
    server: 'AmazonS3' })
