xml = """
<?xml version="1.0" encoding="UTF-8"?>
<Distribution xmlns="http://cloudfront.amazonaws.com/doc/2014-10-21/">
  <Id>E3A4KOLOH12OAV</Id>
  <Status>Deployed</Status>
  <LastModifiedTime>2014-06-01T06:48:08.118Z</LastModifiedTime>
  <InProgressInvalidationBatches>0</InProgressInvalidationBatches>
  <DomainName>d28ayna0xo97kz.cloudfront.net</DomainName>
  <ActiveTrustedSigners>
    <Enabled>false</Enabled>
    <Quantity>0</Quantity>
  </ActiveTrustedSigners>
  <DistributionConfig>
    <CallerReference>1401599979965</CallerReference>
    <Aliases>
      <Quantity>1</Quantity>
      <Items>
        <CNAME>cdn.cine.io</CNAME>
      </Items>
    </Aliases>
    <DefaultRootObject />
    <Origins>
      <Quantity>1</Quantity>
      <Items>
        <Origin>
          <Id>S3-cine-io-production</Id>
          <DomainName>cine-io-production.s3.amazonaws.com</DomainName>
          <S3OriginConfig>
            <OriginAccessIdentity />
          </S3OriginConfig>
        </Origin>
      </Items>
    </Origins>
    <DefaultCacheBehavior>
      <TargetOriginId>S3-cine-io-production</TargetOriginId>
      <ForwardedValues>
        <QueryString>false</QueryString>
        <Cookies>
          <Forward>none</Forward>
        </Cookies>
        <Headers>
          <Quantity>0</Quantity>
        </Headers>
      </ForwardedValues>
      <TrustedSigners>
        <Enabled>false</Enabled>
        <Quantity>0</Quantity>
      </TrustedSigners>
      <ViewerProtocolPolicy>allow-all</ViewerProtocolPolicy>
      <MinTTL>300</MinTTL>
      <AllowedMethods>
        <Quantity>2</Quantity>
        <Items>
          <Method>GET</Method>
          <Method>HEAD</Method>
        </Items>
        <CachedMethods>
          <Quantity>2</Quantity>
          <Items>
            <Method>GET</Method>
            <Method>HEAD</Method>
          </Items>
        </CachedMethods>
      </AllowedMethods>
      <SmoothStreaming>false</SmoothStreaming>
    </DefaultCacheBehavior>
    <CacheBehaviors>
      <Quantity>0</Quantity>
    </CacheBehaviors>
    <CustomErrorResponses>
      <Quantity>0</Quantity>
    </CustomErrorResponses>
    <Comment />
    <Logging>
      <Enabled>false</Enabled>
      <IncludeCookies>false</IncludeCookies>
      <Bucket />
      <Prefix />
    </Logging>
    <PriceClass>PriceClass_All</PriceClass>
    <Enabled>true</Enabled>
    <ViewerCertificate>
      <IAMCertificateId>ASCAIV52CSOSWGT7MIMY4</IAMCertificateId>
      <SSLSupportMethod>sni-only</SSLSupportMethod>
      <MinimumProtocolVersion>TLSv1</MinimumProtocolVersion>
    </ViewerCertificate>
    <Restrictions>
      <GeoRestriction>
        <RestrictionType>none</RestrictionType>
        <Quantity>0</Quantity>
      </GeoRestriction>
    </Restrictions>
  </DistributionConfig>
</Distribution>
"""
module.exports = (options)->
  nock('https://cloudfront.amazonaws.com:443')
    .get("/2014-10-21/distribution/#{options.id}")
    .reply(200, xml, { 'x-amzn-requestid': 'f3091284-70ef-11e4-adff-6b4c98ee5b14',
    etag: options.id,
    'content-type': 'text/xml',
    'content-length': '2175',
    date: 'Thu, 20 Nov 2014 20:00:59 GMT' })
