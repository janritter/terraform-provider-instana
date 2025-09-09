    
export CGO_ENABLED:=0
export GO111MODULE=on
#export GOFLAGS=-mod=vendor

VERSION=$(shell git describe --tags --match "v*" --always --dirty)

.PHONY: all
all: build test vet lint fmt

.PHONY: build
build: clean bin/terraform-provider-instana

install: build copy

bin/terraform-provider-instana:
	@echo "+++++++++++  Run GO Build +++++++++++ "
	@go build -o $@ github.com/gessnerfl/terraform-provider-instana

copy:
	@echo "+++++++++++  Copy binary to local terraform plugins folder +++++++++++ "
	mkdir -p ~/.terraform.d/plugins/terraform.local/local/instana/1.0.0/darwin_arm64
	cp bin/terraform-provider-instana ~/.terraform.d/plugins/terraform.local/local/instana/1.0.0/darwin_arm64/terraform-provider-instana_v1.0.0
	@echo "\n+++++++++++  Plugin installed +++++++++++ "
	@echo "The plugin can now be used by adding the following provider block to your terraform configuration:"
	@echo "  required_providers {"
	@echo "    instana = {"
	@echo "      source  = \"terraform.local/local/instana\""
	@echo "      version = \"1.0.0\""
	@echo "    }"
	@echo "  }"

.PHONY: test
test:
	@echo "+++++++++++  Run GO Test +++++++++++ "
	@go test -v ./... -cover

.PHONY: gosec
gosec:
	@echo "+++++++++++  Run GO SEC +++++++++++ "
	@gosec ./... 

.PHONY: vet
vet:
	@echo "+++++++++++  Run GO VET +++++++++++ "
	@go vet -all ./...

.PHONY: lint
lint:
	@echo "+++++++++++  Run GO Lint +++++++++++ "
	@golangci-lint run

.PHONY: fmt
fmt:
	@echo "+++++++++++  Run GO FMT +++++++++++ "
	@test -z $$(go fmt ./...) 

.PHONY: update
update:
	@GOFLAGS="" go get -u
	@go mod tidy

.PHONY: vendor
vendor:
	@go mod vendor

.PHONY: clean
clean:
	@echo "+++++++++++  Clean up project +++++++++++ "
	@rm -rf bin