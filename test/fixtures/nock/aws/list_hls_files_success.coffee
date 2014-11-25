response = """
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Name>cine-cloudfront-logging</Name>
  <Prefix>hls/publish-sfo1/</Prefix>
  <Marker />
  <MaxKeys>1000</MaxKeys>
  <Delimiter>/</Delimiter>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>hls/publish-sfo1/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz</Key>
    <LastModified>2014-11-24T19:29:47.000Z</LastModified>
    <ETag>"4796813ebc693ffe00f8022d6aa18fda"</ETag>
    <Size>638</Size>
    <Owner>
      <ID>c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0</ID>
      <DisplayName>awsdatafeeds</DisplayName>
    </Owner>
    <StorageClass>STANDARD</StorageClass>
  </Contents>
</ListBucketResult>
"""
module.exports = ->
  nock('https://cine-cloudfront-logging.s3.amazonaws.com:443')
    .get('/?delimiter=%2F&prefix=hls%2Fpublish-sfo1%2F')
    .reply(200, response, { 'x-amz-id-2': 'biD4JwEwQXXUHoGCufhq/Ssno8qX9QsemckXKabNmjImC4x1tQs+dPewGu5RNlzaePSJ0cMKzyQ=',
    'x-amz-request-id': 'D3E529AC6AF0E018',
    date: 'Tue, 25 Nov 2014 03:58:59 GMT',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    server: 'AmazonS3' });
