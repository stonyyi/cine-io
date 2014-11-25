module.exports = ->
  nock('https://cine-cloudfront-logging.s3.amazonaws.com:443')
    .get('/file.txt')
    .reply(200, "this is a file\n", { 'x-amz-id-2': 'UZAIRHXKDFWzpivRk1Jjlk+jqN3iXbpLHMnBFnL6D6aoYaWwGPfcX9Dt36W0C/vM',
    'x-amz-request-id': '33F70812BA826412',
    date: 'Tue, 25 Nov 2014 02:01:54 GMT',
    'last-modified': 'Tue, 25 Nov 2014 02:01:21 GMT',
    etag: '"26bb73556ceb32a5df30b733c5355ee5"',
    'accept-ranges': 'bytes',
    'content-type': 'text/plain',
    'content-length': '15',
    connection: 'close',
    server: 'AmazonS3' });
