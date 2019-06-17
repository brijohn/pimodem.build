
V ?= 0
Q = $(if $(filter 1,$V),,@)
M = $(shell printf "\033[34;1m▶\033[0m")

SHELL = bash
FAKEROOT = fakeroot

.PHONY: all
all: image

.PHONY: image
image: ; $(info $(M) building pimodem image…)
	$Q for f in scripts/??-*; do \
		msg=$$(basename $$f) ; \
		msg=$${msg:3} ; \
		msg=$${msg//[-]/ } ; \
		printf "\033[34;1m▶\033[0m $$msg…\n" ; \
		$(FAKEROOT) $$f ; \
	done

.PHONY: clean
clean: ; $(info $(M) cleaning…)
	@rm -rf build
