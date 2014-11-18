module.exports = (fileName, fileContents)->
  nock('https://cine-io-hls.s3.amazonaws.com:443')
    .put("/#{fileName}", fileContents)
    .reply(200, "", { 'x-amz-id-2': 'pUygvEyjqX1IleQ2RA8UltFJayOTlzieQ89J+3TnZSGetqSk50UWjcs1W3M2FAsT',
    'x-amz-request-id': '03108629EDFF2B6C',
    date: 'Tue, 18 Nov 2014 02:51:09 GMT',
    etag: '"26bb73556ceb32a5df30b733c5355ee5"',
    'content-length': '0',
    server: 'AmazonS3' });
