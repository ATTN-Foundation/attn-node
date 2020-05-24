# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: attn android ios attn-cross evm all test clean
.PHONY: attn-linux attn-linux-386 attn-linux-amd64 attn-linux-mips64 attn-linux-mips64le
.PHONY: attn-linux-arm attn-linux-arm-5 attn-linux-arm-6 attn-linux-arm-7 attn-linux-arm64
.PHONY: attn-darwin attn-darwin-386 attn-darwin-amd64
.PHONY: attn-windows attn-windows-386 attn-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

attn:
	$(GORUN) build/ci.go install ./cmd/attn
	@echo "Done building."
	@echo "Run \"$(GOBIN)/attn\" to launch attn."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/attn.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/attn.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	env GO111MODULE=on go clean -cache
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

attn-cross: attn-linux attn-darwin attn-windows attn-android attn-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/attn-*

attn-linux: attn-linux-386 attn-linux-amd64 attn-linux-arm attn-linux-mips64 attn-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-*

attn-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/attn
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep 386

attn-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/attn
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep amd64

attn-linux-arm: attn-linux-arm-5 attn-linux-arm-6 attn-linux-arm-7 attn-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep arm

attn-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/attn
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep arm-5

attn-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/attn
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep arm-6

attn-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/attn
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep arm-7

attn-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/attn
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep arm64

attn-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/attn
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep mips

attn-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/attn
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep mipsle

attn-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/attn
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep mips64

attn-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/attn
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/attn-linux-* | grep mips64le

attn-darwin: attn-darwin-386 attn-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/attn-darwin-*

attn-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/attn
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/attn-darwin-* | grep 386

attn-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/attn
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/attn-darwin-* | grep amd64

attn-windows: attn-windows-386 attn-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/attn-windows-*

attn-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/attn
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/attn-windows-* | grep 386

attn-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/attn
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/attn-windows-* | grep amd64
