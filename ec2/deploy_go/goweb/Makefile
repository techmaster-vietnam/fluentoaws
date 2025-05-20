.PHONY: all aws

all:
	go build -o goweb main.go

aws:
	GOOS=linux GOARCH=amd64 go build -o goweb main.go

