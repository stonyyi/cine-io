response = """
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Name>cine-cloudfront-logging</Name>
  <Prefix>vod/</Prefix>
  <Marker />
  <MaxKeys>1000</MaxKeys>
  <Delimiter>/</Delimiter>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>vod/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3.gz</Key>
    <LastModified>2014-11-24T01:56:20.000Z</LastModified>
    <ETag>"2801f831b6e5b1a4fd85b321aacf5924"</ETag>
    <Size>811</Size>
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
    .get('/?delimiter=%2F&prefix=vod%2F')
    .reply(200, response, { 'x-amz-id-2': 'diCudSNBLVkCxwNP5ioisT6lxJ2eQtvvosrgmlJmbkecIe2NIkyfJa4VIRjF9Vup',
    'x-amz-request-id': 'AFC92B32219A3D75',
    date: 'Tue, 25 Nov 2014 17:09:50 GMT',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    server: 'AmazonS3' })
