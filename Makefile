# Init SDK and Example projects
init:
	cd Sources; make init

	cd Example; make init

# Init SDK and Example projects
projects:
	cd Sources; make project

	cd Example; make project

# Install git hooks
hooks:
	mkdir -p .git/hooks
	chmod +x commit-msg
	ln -s -f ../../commit-msg .git/hooks/commit-msg

	chmod +x prepare-commit-msg
	ln -s -f ../../prepare-commit-msg .git/hooks/prepare-commit-msg

	chmod +x post-checkout
	ln -s -f ../../post-checkout .git/hooks/post-checkout

	chmod +x post-merge
	ln -s -f ../../post-merge .git/hooks/post-merge
