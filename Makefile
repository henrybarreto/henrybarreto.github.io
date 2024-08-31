DIR=$(PWD)
PORT=4000

check:
	@if ! docker info > /dev/null 2>&1; then \
		echo "Docker is not running."; \
		echo "Starting it"; \
		systemctl start docker; \
	fi
build: check
	docker build -t jekyll .
dev: check build
	docker run \
		--rm -it \
		-v "$(DIR):/srv/jekyll:Z" \
		-p $(PORT):$(PORT) \
		jekyll jekyll serve --drafts --livereload -s /srv/jekyll --host 0.0.0.0 --port $(PORT)
