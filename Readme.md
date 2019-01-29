# Docker-PyOne

[![Docker Repository on Quay](https://quay.io/repository/setzero/pyone/status "Docker Repository on Quay")](https://quay.io/repository/setzero/pyone)
[![Docker Pulls](https://img.shields.io/docker/pulls/setzero/pyone.svg)](https://hub.docker.com/r/setzero/pyone)
[![](https://images.microbadger.com/badges/image/setzero/pyone.svg)](https://microbadger.com/images/setzero/pyone "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/setzero/pyone.svg)](https://microbadger.com/images/setzero/pyone "Get your own version badge on microbadger.com")

> 👋 本项目为 [abbeyokgo/PyOne](https://github.com/abbeyokgo/PyOne) docker镜像版本。受 [thanch2n/pyone](https://hub.docker.com/r/thanch2n/pyone) 启发，借鉴其部分功能，在这里向这两个项目的作者表示感谢。

## 版本：

- `latest`：以debian为基础系统，跟踪 [abbeyokgo/PyOne](https://github.com/abbeyokgo/PyOne) 的最新提交。
- `alpine`：以alpine为基础系统，跟踪 [abbeyokgo/PyOne](https://github.com/abbeyokgo/PyOne) 的最新提交。
- `debian-commit_sha`：以debian为基础系统，[abbeyokgo/PyOne](https://github.com/abbeyokgo/PyOne) Commit sha对应的提交。
- `alpine-commit_sha`：以alpine为基础系统，[abbeyokgo/PyOne](https://github.com/abbeyokgo/PyOne) Commit sha对应的提交。

## 运行：

- 使用`docker run`命令运行：

    ```
    docker run -d --name pyone \
        -p 80:80 --restart=always \
        -e REFRESH_CACHE_NEW='*/15 * * * *' \
        -e REFRESH_CACHE_ALL='0 3 */1 * *' \
        -v ~/pyone/data:/data \
        -v ~/pyone/PyOne:/root/PyOne \
        setzero/pyone
    ```

    - 停止删除容器：
        ```
        docker stop pyone
        docker rm -v pyone
        ```

- 使用`docker-compose`运行：

    ```
    docker-compose up -d
    ```

    - 停止删除容器：
        ```
        docker-compose down
        ```

## 变量：

- `TZ`：时区，默认`Asia/Shanghai`
- `PORT`：服务监听端口，默认为80
- `DISABLE_REFRESH_CACHE`：是否禁用crontab自动刷新缓存，设置任意值则不启用
- `REFRESH_CACHE_NEW`：使用crontab进行增量更新，默认`*/15 * * * *`，即每15分钟更新一次
- `REFRESH_CACHE_ALL`：使用crontab进行全量更新，默认`0 3 */1 * *`，即每天凌晨3点更新一次
- `SSH_PASSWORD`：sshd用户密码，用户名为`root`，若不设置则不启用sshd
- `ARIA2_SECRET`：aria2的rpc secret，默认`aria2-secret`
- `HEALTHCHECK_INTERVAL`：健康检查间隔周期，默认`3`秒。

## 持久化：

- `/data`：mongodb及aria2的配置文件及数据
- `/root/PyOne`：PyOne源代码