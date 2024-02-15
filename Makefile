 .PHONY: all ${MAKECMDGOALS}

MOLECULE_SCENARIO ?= default
MOLECULE_DOCKER_IMAGE ?= ubuntu2004
GALAXY_API_KEY ?=
GITHUB_REPOSITORY ?= $$(git config --get remote.origin.url | cut -d: -f 2 | cut -d. -f 1)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)
REQUIREMENTS = requirements.yml
DEBIAN_SHASUMS = https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
DEBIAN_MIRROR = $$(dirname ${DEBIAN_SHASUMS})
DEBIAN_ISO = $$(curl -s ${DEBIAN_SHASUMS} | grep "debian-[0-9]" | awk '{print $$2}')

all: install version lint test

test: lint
	MOLECULE_ISO=${DEBIAN_MIRROR}/${DEBIAN_ISO} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

install:
	@type poetry >/dev/null || pip3 install poetry
	@sudo apt-get install -y libvirt-dev
	@poetry install --no-root

lint: install
	poetry run yamllint .
	poetry run ansible-lint .
	poetry run molecule syntax

roles:
	[ -f ${REQUIREMENTS} ] && yq '.$@[] | .name' -r < ${REQUIREMENTS} \
		| xargs -L1 poetry run ansible-galaxy role install --force || exit 0

collections:
	[ -f ${REQUIREMENTS} ] && yq '.$@[]' -r < ${REQUIREMENTS} \
		| xargs -L1 echo poetry run ansible-galaxy -vvv collection install --force || exit 0

requirements: roles collections

dependency create prepare converge idempotence side-effect verify destroy login reset:
	MOLECULE_ISO=${DEBIAN_MIRROR}/${DEBIAN_ISO} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

ignore:
	poetry run ansible-lint --generate-ignore

clean: destroy reset
	@poetry env remove $$(which python) >/dev/null 2>&1 || exit 0

publish:
	@echo publishing repository ${GITHUB_REPOSITORY}
	@echo GITHUB_ORGANIZATION=${GITHUB_ORG}
	@echo GITHUB_REPOSITORY=${GITHUB_REPO}
	@poetry run ansible-galaxy role import \
		--api-key ${GALAXY_API_KEY} ${GITHUB_ORG} ${GITHUB_REPO}

version:
	@poetry run molecule --version

debug: version
	@poetry export --dev --without-hashes
	sudo ufw status
