DIR=$(PWD)
PORT=4000

build: 
	podman build -t jekyll .
dev: build
	podman run \
		--rm -it \
		--network host \
		-v "$(DIR):/srv/jekyll:Z" \
		jekyll jekyll serve --drafts --livereload -s /srv/jekyll --host localhost --port $(PORT)
