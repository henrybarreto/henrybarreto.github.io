FROM alpine

RUN apk add jekyll

RUN gem install webrick

RUN gem install jekyll-paginate

EXPOSE 4000
