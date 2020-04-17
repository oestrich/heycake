FROM grapevinehaus/elixir:1.10.0-alpine-1 as builder
RUN apk update && \
      apk upgrade --no-cache && \
      apk add --no-cache gcc git make musl-dev && \
      mix local.rebar --force && \
      mix local.hex --force
WORKDIR /app/
ENV MIX_ENV=prod
COPY mix.* /app/
RUN mix deps.get --only prod && \
  mix deps.compile

FROM node:10.9 as frontend
WORKDIR /app
COPY assets/package.json assets/yarn.lock /app/
COPY --from=builder /app/deps/phoenix /deps/phoenix
COPY --from=builder /app/deps/phoenix_html /deps/phoenix_html
RUN npm install -g yarn && yarn install
COPY assets /app
RUN yarn run deploy

FROM builder as releaser
COPY --from=frontend /priv/static /app/priv/static
COPY . /app/
RUN mix phx.digest && \
  mix release

FROM alpine:3.11
ENV LANG=C.UTF-8
RUN apk update && \
  apk add -U bash openssl imagemagick && \
  rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=releaser /app/_build/prod/rel/hey_cake /app/

EXPOSE 4000

ENTRYPOINT ["bin/hey_cake"]
CMD ["start"]
