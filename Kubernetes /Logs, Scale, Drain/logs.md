# Monitor the logs of pod

```
k logs pod2 > /tmp/logbar.txt
cat /tmp/logbar.txt 
2023-04-18 05:16:31+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.33-1.el8 started.
2023-04-18 05:16:31+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2023-04-18 05:16:31+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.33-1.el8 started.
2023-04-18 05:16:31+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
    You need to specify one of the following as an environment variable:
    - MYSQL_ROOT_PASSWORD
    - MYSQL_ALLOW_EMPTY_PASSWORD
    - MYSQL_RANDOM_ROOT_PASSWORD
```
