DIR=$(PWD)
PORT=4000

build: 
	docker build -f Containerfile -t jekyll .
dev: build
	docker run \
		--rm -it \
		--network host \
		-v "$(DIR):/srv/jekyll:Z" \
		jekyll jekyll serve --drafts --livereload -s /srv/jekyll --host localhost --port $(PORT)
