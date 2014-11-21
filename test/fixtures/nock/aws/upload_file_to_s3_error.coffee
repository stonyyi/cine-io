module.exports = (fileName, fileContents)->
  nock('https://cine-io-hls2.s3.amazonaws.com:443')
    .put("/#{fileName}", fileContents)
    .reply(404, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Error><Code>NoSuchBucket</Code><Message>The specified bucket does not exist</Message><BucketName>cine-io-hls2</BucketName><RequestId>C583C3B5D43D58DF</RequestId><HostId>5AMRpnQKDDeZBGgu4nkxMjNbmnnmgT14U/SvOIRNImTaiu7x127EdIoAyLDNMyyC</HostId></Error>", { 'x-amz-request-id': 'C583C3B5D43D58DF',
    'x-amz-id-2': '5AMRpnQKDDeZBGgu4nkxMjNbmnnmgT14U/SvOIRNImTaiu7x127EdIoAyLDNMyyC',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    date: 'Tue, 18 Nov 2014 03:01:13 GMT',
    connection: 'close',
    server: 'AmazonS3' })
