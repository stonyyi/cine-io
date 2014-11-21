module.exports = ->
  nock('https://cine-io-hls2.s3.amazonaws.com:443')
    .get('/?delimiter=%2F&prefix=')
    .reply(404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error><Code>NoSuchBucket</Code><Message>The specified bucket does not exist</Message><BucketName>cine-io-hls2</BucketName><RequestId>EE3C686C29D86282</RequestId><HostId>RglOKLjAxMEXBJ6mL+QECm+jehYoY7/bRTticRiCYhs+eo5KL6QrPOdVgNnE65RB</HostId></Error>", { 'x-amz-request-id': 'EE3C686C29D86282',
    'x-amz-id-2': 'RglOKLjAxMEXBJ6mL+QECm+jehYoY7/bRTticRiCYhs+eo5KL6QrPOdVgNnE65RB',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    date: 'Fri, 21 Nov 2014 21:18:10 GMT',
    server: 'AmazonS3' })
