## Fluentd - MySQL

> 알림 통합 서비스의 각 3rd party 알림 발송 앱이 알림을 발송했을 때의 결과를 처리하는 도커 컨테이너

- fluentd container : 해당 컨테이너가 각각의 알림 발송 결과를 수집 및 mysql container에 적재
- mysql container : 알림 발송 결과 저장

## Fluentd

- `fluent-plugin-mysql-bulk` : 플러그인 설치
- `volumes: ./conf:/fluentd/etc` : 볼륨 연결 (fluentd의 설정 파일)
- `24224:24224` : 포트 연결
- `depends_on: db` : mysql container 생성 후 fluentd container 생성
- conf 설정
    ```conf
        <source>
        @type forward
        port 24224
        bind 0.0.0.0
        </source>

        <match alarm.request.**>
        @type mysql_bulk
        host mysql-service
        database fluentd-test
        username root
        password 1234
        column_names request_id,title,content,user_id,created_at
        table alarm_requests
        flush_interval 10s
        <store>
            @type stdout
        </store>
        </match>
        <match alarm.result.**>
        @type mysql_bulk
        host mysql-service
        database fluentd-test
        username root
        password 1234
        column_names id,request_id,app_name,address,log_message,is_success
        table alarm_results
        flush_interval 10s
        <store>
            @type stdout
        </store>
        </match>
    ```

## MySQL

- version : 5.7
- `3306:3306` : 포트 연결
- `./db_data:/var/lib/mysql` : 볼륨 연결 (컨테이너가 중단되었다가 시작되어도 데이터 초기화 x)
- `./dump/:/docker-entrypoint-initdb.d/` : 볼륨 연결 (컨테이너가 생성되고 시작될 때 읽어들이는 파일 -> init.sql로 설정)
- init.sql
    ```sql
    CREATE DATABASE IF NOT EXISTS `fluentd-test`;

    USE fluentd-test;

    CREATE TABLE IF NOT EXISTS `logs` (
        `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT NOT NULL,
        `app_name` VARCHAR(100) NOT NULL,
        `trace_id` VARCHAR(512) NOT NULL,
        `result_msg` VARCHAR(512) NOT NULL,
        `created_at` TIMESTAMP NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    CREATE TABLE IF NOT EXISTS `users` (
        `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `password` VARCHAR(255) NOT NULL,
        `username` VARCHAR(20) NOT NULL,
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ```