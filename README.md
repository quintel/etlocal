# ETLocal

[![Build Status](https://quintel.semaphoreci.com/badges/etlocal/branches/production.svg?style=shields)](https://quintel.semaphoreci.com/projects/etlocal)

Countries, provinces, municipalities, districts and neighborhoods have their own unique
questions for their energy systems. The ETM dataset manger (etlocal) provides a way to get meaningful
insight into their current situation and allows to customize and create stable,
transparent present situations for usage inside of ETModel.

### To install:

1. Config files:

```
cp config/database.sample.yml config/database.yml
cp config/email.sample.yml config/email.yml
```

2. Run `rake db:create`

3. Add a `.env` file with a mapbox api key to enable the map on your local environment. You can copy the template `.env.template` and fill in the key there, or create your own file like such:

```bash
echo "MAPBOX_API_KEY=xx.xxxxxxxxxxxxxxxxxxxxxxxxx" >> .env
```

The x's should be replaced by the mapbox api key.

### Useful reading

* [Creating data migrations](https://docs.energytransitionmodel.com/contrib/dataset-manager/data-migrations)

