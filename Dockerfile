FROM alpine

RUN apk add jekyll

RUN gem install webrick

RUN gem install jekyll-paginate

EXPOSE 4000

CMD [ "jekyll", "serve", "-s /srv/jekyll","--host 0.0.0.0", "--port 4000" ]
