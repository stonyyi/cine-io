xmlPost = (options)->
  if !options.logging
    logging =
      """
      <Logging>
        <Enabled>false</Enabled>
        <IncludeCookies>false</IncludeCookies>
        <Bucket></Bucket>
        <Prefix></Prefix>
      </Logging>
      """
  else
    logging =
      """
      <Logging>
        <Enabled>true</Enabled>
        <IncludeCookies>false</IncludeCookies>
        <Bucket>#{options.logging.bucket}</Bucket>
        <Prefix>#{options.logging.prefix}</Prefix>
      </Logging>
      """
  """
  <DistributionConfig xmlns="http://cloudfront.amazonaws.com/doc/2014-10-21/">
    <CallerReference>#{options.callerReference}</CallerReference>
    <Aliases>
      <Quantity>0</Quantity>
      <Items/>
    </Aliases>
    <DefaultRootObject></DefaultRootObject>
    <Origins>
      <Quantity>1</Quantity>
      <Items>
        <Origin>
          <Id>Custom-#{options.origin}</Id>
          <DomainName>#{options.origin}</DomainName>
          <CustomOriginConfig>
            <HTTPPort>80</HTTPPort>
            <HTTPSPort>443</HTTPSPort>
            <OriginProtocolPolicy>match-viewer</OriginProtocolPolicy>
          </CustomOriginConfig>
        </Origin>
      </Items>
    </Origins>
    <DefaultCacheBehavior>
      <TargetOriginId>Custom-#{options.origin}</TargetOriginId>
      <ForwardedValues>
        <QueryString>false</QueryString>
        <Cookies>
          <Forward>none</Forward>
          <WhitelistedNames>
            <Quantity>0</Quantity>
            <Items/>
          </WhitelistedNames>
        </Cookies>
        <Headers>
          <Quantity>0</Quantity>
          <Items/>
        </Headers>
      </ForwardedValues>
      <TrustedSigners>
        <Enabled>false</Enabled>
        <Quantity>0</Quantity>
        <Items/>
      </TrustedSigners>
      <ViewerProtocolPolicy>allow-all</ViewerProtocolPolicy>
      <MinTTL>0</MinTTL>
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
      <Items/>
    </CacheBehaviors>
    <CustomErrorResponses>
      <Quantity>0</Quantity>
      <Items/>
    </CustomErrorResponses>
    <Comment></Comment>
    #{logging}
    <PriceClass>PriceClass_All</PriceClass>
    <Enabled>true</Enabled>
    <ViewerCertificate>
      <CloudFrontDefaultCertificate>true</CloudFrontDefaultCertificate>
      <SSLSupportMethod>sni-only</SSLSupportMethod>
      <MinimumProtocolVersion>TLSv1</MinimumProtocolVersion>
    </ViewerCertificate>
    <Restrictions>
      <GeoRestriction>
        <RestrictionType>none</RestrictionType>
        <Quantity>0</Quantity>
        <Items/>
      </GeoRestriction>
    </Restrictions>
  </DistributionConfig>
  """.replace(/(\n|\s{2,})/g, '')

xmlResponse = (options)->
  """
  <?xml version="1.0" encoding="UTF-8"?>
  <Distribution xmlns="http://cloudfront.amazonaws.com/doc/2014-10-21/">
    <Id>EQGIDG4E7DZCZ</Id>
    <Status>InProgress</Status>
    <LastModifiedTime>2014-11-20T20:34:51.226Z</LastModifiedTime>
    <InProgressInvalidationBatches>0</InProgressInvalidationBatches>
    <DomainName>dsjomk4nfwryz.cloudfront.net</DomainName>
    <ActiveTrustedSigners>
      <Enabled>false</Enabled>
      <Quantity>0</Quantity>
    </ActiveTrustedSigners>
    <DistributionConfig>
      <CallerReference>#{options.callerReference}</CallerReference>
      <Aliases>
        <Quantity>0</Quantity>
      </Aliases>
      <DefaultRootObject />
      <Origins>
        <Quantity>1</Quantity>
        <Items>
          <Origin>
            <Id>Custom-#{options.origin}</Id>
            <DomainName>#{options.origin}</DomainName>
            <CustomOriginConfig>
              <HTTPPort>80</HTTPPort>
              <HTTPSPort>443</HTTPSPort>
              <OriginProtocolPolicy>match-viewer</OriginProtocolPolicy>
            </CustomOriginConfig>
          </Origin>
        </Items>
      </Origins>
      <DefaultCacheBehavior>
        <TargetOriginId>Custom-#{options.origin}</TargetOriginId>
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
        <MinTTL>0</MinTTL>
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
        <CloudFrontDefaultCertificate>true</CloudFrontDefaultCertificate>
        <MinimumProtocolVersion>SSLv3</MinimumProtocolVersion>
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
    .post('/2014-10-21/distribution', xmlPost(options))
    .reply(201, xmlResponse(options), { 'x-amzn-requestid': 'ad7032a7-70f4-11e4-abe2-9f01b2465fcd',
    etag: 'E3FKJK2Y5VIDPV',
    location: 'https://cloudfront.amazonaws.com/2014-10-21/distribution/EQGIDG4E7DZCZ',
    'content-type': 'text/xml',
    'content-length': '2152',
    date: 'Thu, 20 Nov 2014 20:34:51 GMT' })
