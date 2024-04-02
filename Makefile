DIR=$(PWD)

dev:
	docker run --rm -it --volume="$(DIR):/srv/jekyll:Z" -p 4000:4000 jekyll/jekyll /bin/sh -c "gem install webrick && jekyll serve"
