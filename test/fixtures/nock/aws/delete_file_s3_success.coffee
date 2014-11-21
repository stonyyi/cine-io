module.exports = (bucket, fileName)->
  nock("https://#{bucket}.s3.amazonaws.com:443")
    .post('/?delete', "<Delete xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Object><Key>#{fileName}</Key></Object></Delete>")
    .reply(200, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<DeleteResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Deleted><Key>some-stream-1416429958807.ts</Key></Deleted></DeleteResult>", { 'x-amz-id-2': 'dR/jOF97lbHhrLgQGgspx64OD7n4a+V8/PGKgE/ffaijx+ILR5bRqcyTrrfosBcC',
    'x-amz-request-id': '906BF8241D0C825D',
    date: 'Fri, 21 Nov 2014 21:40:55 GMT',
    connection: 'close',
    'content-type': 'application/xml',
    'transfer-encoding': 'chunked',
    server: 'AmazonS3' })
