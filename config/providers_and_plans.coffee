humanizeBytes = Cine.lib('humanize_bytes')

module.exports =
  'cine.io':
    url: 'https://www.cine.io'
    plans:
      free:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
      solo:
        price: 20
        bandwidth: humanizeBytes.GiB * 20
        storage: humanizeBytes.GiB * 5
        bandwidthOverage: 0.9
        storageOverage: 0.9
      basic:
        price: 100
        bandwidth: humanizeBytes.GiB * 150
        storage: humanizeBytes.GiB * 25
        bandwidthOverage: 0.8
        storageOverage: 0.8
      pro:
        price: 500
        bandwidth: humanizeBytes.TiB
        storage: humanizeBytes.GiB * 100
        bandwidthOverage: 0.7
        storageOverage: 0.7
  heroku:
    url: 'https://addons.heroku.com/cine'
    plans:
      starter:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
        bandwidthOverage: 0
        storageOverage: 0
      test:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
        storageOverage: 0
        storageOverage: 0

  engineyard:
    url: 'https://addons.engineyard.com/cine.io'
    plans:
      test:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
        bandwidthOverage: 0
        storageOverage: 0
      starter:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
        bandwidthOverage: 0
        storageOverage: 0
      solo:
        price: 20
        bandwidth: humanizeBytes.GiB * 20
        storage: humanizeBytes.GiB * 5
        bandwidthOverage: 0
        storageOverage: 0
      basic:
        price: 100
        bandwidth: humanizeBytes.GiB * 150
        storage: humanizeBytes.GiB * 25
        bandwidthOverage: 0
        storageOverage: 0
      pro:
        price: 500
        bandwidth: humanizeBytes.TiB
        storage: humanizeBytes.GiB * 100
        bandwidthOverage: 0
        storageOverage: 0

  appdirect:
    # Url likely to change once we're approved
    # I heard something about a dev profile and public profile
    url: 'https://www.appdirect.com/apps/12055'
    plans:
      'sample-addon':
        price: 0
        bandwidth: humanizeBytes.GiB
      starter:
        price: 0
        bandwidth: humanizeBytes.GiB
        storage: 0
        bandwidthOverage: 0
        storageOverage: 0
      solo:
        price: 20
        bandwidth: humanizeBytes.GiB * 20
        storage: humanizeBytes.GiB * 5
        bandwidthOverage: 0
        storageOverage: 0
      basic:
        price: 100
        bandwidth: humanizeBytes.GiB * 150
        storage: humanizeBytes.GiB * 25
        bandwidthOverage: 0
        storageOverage: 0
      pro:
        price: 500
        bandwidth: humanizeBytes.TiB
        storage: humanizeBytes.GiB * 100
        bandwidthOverage: 0
        storageOverage: 0
