# 使用官方的Golang Alpine镜像作为构建阶段的基础镜像
FROM golang:alpine AS builder

# 设置工作目录并切换到该目录
WORKDIR /build

# 将当前目录下的Go模组文件复制到容器中，先下载依赖再删除模组文件以减少镜像大小
COPY go.mod go.sum ./
RUN go mod download
RUN rm go.mod go.sum

# 复制整个应用程序代码到容器中并编译
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# 使用Alpine作为运行时的基础镜像，保持镜像轻量
FROM alpine:latest

# 添加必需的CA证书以确保HTTPS请求正常工作
RUN apk --no-cache add ca-certificates

# 设置工作目录并从构建阶段复制编译好的二进制文件
WORKDIR /app
COPY --from=builder /build/main /app/

# 设置非root用户并切换用户上下文，提高安全性
RUN adduser -D -g '' appuser
USER appuser

# 暴露应用端口
EXPOSE 8080

# 指定容器启动命令
CMD ["./main"]