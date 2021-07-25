FROM alpine:3.14 as build
ENV LANG=C.UTF-8
ENV MIX_ENV=prod
RUN mkdir /app
WORKDIR /app
RUN apk update \
 && apk add elixir nodejs yarn \
 && rm /var/cache/apk/* \
 && mix local.hex --force \
 && mix local.rebar --force
COPY . /app
RUN ./scripts/release.sh

FROM alpine:3.14
RUN apk update \
 && apk add libgcc ncurses-terminfo-base ncurses-libs libstdc++ \
 && rm /var/cache/apk/*
EXPOSE 4000
RUN mkdir /app
WORKDIR /app
COPY --from=build /app/_build/prod/rel/wargames /app
RUN addgroup -S wargames \
 && adduser -S wargames -G wargames \
 && chown wargames:wargames /app
USER wargames
CMD ["/app/bin/wargames", "start"]
