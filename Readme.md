# Docker-PyOne

> 👋 本项目受 [thanch2n/pyone](https://hub.docker.com/r/thanch2n/pyone) 启发，借鉴其部分功能，在这里感谢。

## 运行：

- 使用`docker run`命令运行：

    ```
    docker run -d --name pyone \
        -p 80:34567 --restart=always \
        -e TZ='Asia/Shanghai' \
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

- `TZ`：时区，默认为UTC标准时区
- `PORT`：服务监听端口
- `DISABLE_CRON`：是否禁用crontab自动刷新缓存，设置任意值则不启用
- `REFRESH_CACHE_NEW`：使用crontab进行增量更新，默认`*/15 * * * *`，即每15分钟更新一次
- `REFRESH_CACHE_ALL`：使用crontab进行全量更新，默认`0 3 */1 * *`，即每天凌晨3点更新一次
- `SSH_PASSWORD`：sshd用户密码，用户名为`root`，若不设置则不启用sshd

## 持久化：

- `/data`：mongodb及aria2的配置文件及数据
- `/root/PyOne`：PyOne源代码