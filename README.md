# HeyCake

heycake is a way to track callouts for your team in slack.

## Docker locally

Docker is set up as a replication of production. This generates an erlang release and is not intended for development purposes.

```bash
docker-compose pull
docker-compose build
docker-compose up -d postgres
docker-compose run --rm app eval "HeyCake.ReleaseTasks.Migrate.run()"
docker-compose up app
```

You now can view `http://localhost:4000` and access the application.
