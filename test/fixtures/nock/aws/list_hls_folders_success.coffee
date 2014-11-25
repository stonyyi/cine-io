response = """
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Name>cine-cloudfront-logging</Name>
  <Prefix>hls/</Prefix>
  <Marker />
  <MaxKeys>1000</MaxKeys>
  <Delimiter>/</Delimiter>
  <IsTruncated>false</IsTruncated>
  <CommonPrefixes>
    <Prefix>hls/publish-sfo1/</Prefix>
  </CommonPrefixes>
</ListBucketResult>
"""
module.exports = ->
  nock('https://cine-cloudfront-logging.s3.amazonaws.com:443')
    .get('/?delimiter=%2F&prefix=hls%2F')
    .reply(200, response, { 'x-amz-id-2': 'oObkaDXBMTwd+7KZ4ETIW4l1dL8Xsicn0c/nKLoObAtR1BGhhR9Jl8BNZZK5LKWd',
    'x-amz-request-id': 'D6A67CE70D894927',
    date: 'Tue, 25 Nov 2014 03:56:42 GMT',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    server: 'AmazonS3' });
