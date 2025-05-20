package main

import (
	"github.com/kataras/iris/v12"
)

func main() {
	app := iris.New()

	// Định nghĩa route cho path "/"
	app.Get("/", func(ctx iris.Context) {
		ctx.HTML("<h1>Hello World, Welcome to Golang</h1>")
	})

	// Chạy server trên cả HTTP (80) và HTTPS (443)
	// Lưu ý: Bạn cần có chứng chỉ SSL hợp lệ để chạy HTTPS
	app.Listen("0.0.0.0:80")
}
