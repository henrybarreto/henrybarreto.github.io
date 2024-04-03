DIR=$(PWD)

build:
	docker build -t jekyll .
dev:
	docker run \
		--rm -it \
		-v "$(DIR):/srv/jekyll:Z" \
		-p 4000:4000 \
		jekyll jekyll serve --livereload -s /srv/jekyll --host 0.0.0.0 --port 4000
