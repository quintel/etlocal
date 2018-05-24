# ETLocal

[![Build Status](https://travis-ci.org/quintel/etlocal.svg?branch=master)](https://travis-ci.org/quintel/etlocal)

Provinces, municipalities, districts and neighborhoods have their own unique
questions for their energy systems. ETLocal provides a way to get meaningful
insight into their current situation and allows to customize and create stable,
transparent present situations for usage inside of ETModel.

### To install:

1. Config files:

```
cp config/database.sample.yml config/database.yml
cp config/email.sample.yml config/email.yml
```

2. Copy the [dataset defaults](db/datasets/README.md)

3. Run `rake db:create`, `rake db:schema:load` and `rake db:seed`

4. Add a `.env` file with a mapbox api key to enable the map on your local environment. Like such:

```bash
echo "MAPBOX_API_KEY=xx.xxxxxxxxxxxxxxxxxxxxxxxxx" >> .env
```

The x's should be replaced by the mapbox api key.

