module.exports =
  accessKeyId: process.env.S3_ACCESS_KEY_ID || "fake-access-key"
  secretAccessKey: process.env.S3_SECRET_ACCESS_KEY || "fake-secret-key"
  hlsBucket: process.env.S3_HLS_BUCKET || "cine-io-hls"
  hlsCloudfrontUrl: process.env.S3_HLS_CLOUDFRONT_URL || "https://cine-io-hls.s3.amazonaws.com/"
