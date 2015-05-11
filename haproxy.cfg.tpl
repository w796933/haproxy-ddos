{% macro ddos_protection() -%}
    # ~~~ DDoS protection ~~~
    # HAproxy tracks client IPs into a global stick table. Each IP is
    # stored for a limited amount of time, with several counters attached
    # to it. When a new connection comes in, the stick table is evaluated
    # to verify that the new connection from this client is allowed to
    # continue.

    # Enable tracking of counters for ip in the default stick-table, using CF-Connecting-IP or X-Forwarded-For
    acl HAS_CF_CONNECTING_IP hdr_cnt(CF-Connecting-IP) eq 1
    acl HAS_X_FORWARDED_FOR hdr_cnt(X-Forwarded-For) eq 1
    tcp-request content track-sc0 hdr_ip(CF-Connecting-IP,-1) if HTTP HAS_CF_CONNECTING_IP
    tcp-request content track-sc0 hdr_ip(X-Forwarded-For,-1) if HTTP !HAS_CF_CONNECTING_IP HAS_X_FORWARDED_FOR

    # Stick Table Definitions
    #  - conn_cur: count active connections
    #  - conn_rate(3s): average incoming connection rate over 3 seconds
    #  - http_err_rate(10s): Monitors the number of errors generated by an IP over a period of 10 seconds
    #  - http_req_rate(10s): Monitors the number of request sent by an IP over a period of 10 seconds
    stick-table type ip size 500k expire 30s store conn_cur,conn_rate(3s),http_req_rate(10s),http_err_rate(10s)

    # TARPIT the new connection if the client already has 10 opened
    http-request tarpit if { src_conn_cur ge 10 }

    # TARPIT the new connection if the client has opened more than 20 connections in 3 seconds
    http-request tarpit if { src_conn_rate ge 20 }

    # TARPIT the connection if the client has passed the HTTP error rate (10s)
    http-request tarpit if { sc0_http_err_rate() gt 20 }

    # TARPIT the connection if the client has passed the HTTP request rate (10s)
    http-request tarpit if { sc0_http_req_rate() gt 100 }

    # For country blocking and blacklists, if no CF-Connecting-IP is present, use the last value of X-Forwarded-For
    acl HAS_CF_CONNECTING_IP req.fhdr(CF-Connecting-IP) -m found
    http-request set-header CF-Connecting-IP %[req.hdr_ip(X-Forwarded-For,-1)] if !HAS_CF_CONNECTING_IP
{%- endmacro %}

{% macro whitelist() -%}
    http-request allow if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/whitelist.txt }
{%- endmacro %}

{% macro country_block() -%}
    # Maximum allowed time to wait for data during content inspection. Note that the client timeout must cover at
    # least the inspection delay, otherwise it will expire first. If the client closes the connection or if the buffer
    # is full, the delay immediately expires since the contents will not be able to change anymore.
    tcp-request inspect-delay 5s

    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/AF.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/CI.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/CU.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/EE.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/EG.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/ER.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/ID.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/IR.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/IQ.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/LB.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/LR.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/LY.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/MM.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/MY.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/KP.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/KR.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/RO.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/RS.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/SO.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/SD.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/SY.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/TH.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/TR.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/UA.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/VN.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/YE.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/ZW.txt }
{%- endmacro %}

{% macro blacklist_scammers() -%}
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/exploited-servers.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/nigerian-scammers.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/other-scammers.txt }
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/maxmind-proxies.txt }
{%- endmacro %}

{% macro blacklist_tor() -%}
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/tor-exit-nodes.txt }
{%- endmacro %}

{% macro blacklist_vps() -%}
    http-request deny if { req.hdr_ip(CF-Connecting-IP,-1) -f /etc/haproxy-ddos/blacklists/vps.txt }
{%- endmacro %}

{% macro block_bad_requests() -%}
    acl FORBIDDEN_HDR hdr_cnt(host) gt 1
    acl FORBIDDEN_HDR hdr_cnt(content-length) gt 1
    acl FORBIDDEN_HDR hdr_val(content-length) lt 0
    acl FORBIDDEN_HDR hdr_cnt(proxy-authorization) gt 0
    acl FORBIDDEN_HDR hdr_cnt(x-xsrf-token) gt 1
    acl FORBIDDEN_HDR hdr_len(x-xsrf-token) gt 36
    http-request tarpit if FORBIDDEN_HDR

    acl FORBIDDEN_URI url_reg -i .*(\.|%2e)(\.|%2e)(%2f|%5c|/|\\\\)
    acl FORBIDDEN_URI url_sub -i %00 <script xmlrpc.php
    acl FORBIDDEN_URI path_beg /_search /_nodes
    acl FORBIDDEN_URI path_end -i .ida .asp .dll .exe .php .sh .pl .py .so
    acl FORBIDDEN_URI path_dir -i chat phpbb sumthin horde _vti_bin MSOffice
    http-request tarpit if FORBIDDEN_URI

    # TARPIT content-length larger than 20kB
    acl REQUEST_TOO_BIG hdr_val(content-length) gt 20000
    http-request deny if METH_POST REQUEST_TOO_BIG

    # TARPIT requests with more than 10 Range headers
    acl WEIRD_RANGE_HEADERS hdr_cnt(Range) gt 10
    http-request tarpit if WEIRD_RANGE_HEADERS
{%- endmacro %}

global
    {% if LOGSTASH_SERVICE_HOST is defined %}
    log                     {{ LOGSTASH_SERVICE_HOST }}:5140 len 4096 local0
    log                     {{ LOGSTASH_SERVICE_HOST }}:5140 len 4096 local1 notice
    {% endif %}

    pidfile                 /var/run/haproxy-ddos.pid
    tune.comp.maxlevel      5
    maxcompcpuusage         98
    maxconn                 30000
    spread-checks           5

    tune.ssl.default-dh-param 2048

    # lower the record size to improve Time to First Byte (TTFB)
    tune.ssl.maxrecord      1419

    ssl-default-bind-ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA

    # turn on stats unix socket
    stats socket /var/run/haproxy-ddos mode 600 level operator
    stats timeout 2m

defaults
    log global
    mode http
    option dontlognull
    option splice-response
    option http-keep-alive
    option clitcpka
    option srvtcpka
    option tcp-smart-accept
    option tcp-smart-connect
    option contstats
    retries 3

    timeout http-request    5s
    timeout http-keep-alive 5s
    timeout connect         5s
    timeout client          60s
    timeout client-fin      60s
    timeout tunnel          40m         # timeout to use with WebSocket and CONNECT
    timeout server          150s
    timeout tarpit          15s
    timeout queue           10s

    compression algo gzip
    compression type text/html text/html;charset=utf-8 text/plain text/css text/javascript application/javascript application/x-javascript text/xml application/json application/xml font/truetype application/x-font-ttf

userlist stats-auth
    group admin             users admin
    user  admin             insecure-password FeYskS2qjP7qvED
    group readonly          users haproxy
    user  haproxy           insecure-password haproxy

frontend stats
    acl AUTH http_auth(stats-auth)
    acl AUTH_ADMIN http_auth_group(stats-auth) admin

    bind                    0.0.0.0:9090
    stats                   enable
    stats                   show-legends
    stats uri               /haproxy?stats
    stats refresh           5s
    stats http-request auth unless AUTH
    stats admin             if AUTH_ADMIN

frontend web
    bind 0.0.0.0:443 tfo ssl crt /etc/ssl/private/ no-sslv3 npn http/1.1
    option httplog

    # DO NOT CHANGE THESE UNLESS CHANGING LOGSTASH CONFIG
    capture request header Host len 64
    capture request header X-Forwarded-For len 64
    capture request header Accept-Language len 64
    capture request header Referer len 64
    capture request header User-Agent len 128
    capture request header CF-IPCountry len 64
    capture request header CF-Connecting-IP len 64
    capture request header CF-RAY len 64
    capture request header Content-Length len 10
    capture request header X-Haproxy-ACL len 256
    capture request header X-Haproxy-TARPIT len 256

    acl BACKEND_DEAD nbsrv(app) lt 1
    acl BACKEND_DEAD nbsrv(api) lt 1
    monitor-uri /ping
    monitor fail if BACKEND_DEAD

    # Add the X-Forwarded-For header
    option forwardfor except 127.0.0.0/8

    {{ ddos_protection() }}

    acl IS_API hdr_beg(host) -i api.

    {{ whitelist() }}
    {{ country_block() }}
    {{ block_bad_requests() }}

    acl BADBOT hdr_reg(User-Agent) -i -f /etc/haproxy-ddos/blacklists/badbots.txt
    http-request deny if !IS_API BADBOT

    acl BADREFERER hdr_sub(Referer) -i -f /etc/haproxy-ddos/blacklists/badreferer.txt
    http-request deny if !IS_API BADREFERER

    {{ blacklist_scammers() }}
    {{ blacklist_tor() }}

    use_backend api if IS_API

    default_backend app

backend app
    {{ whitelist() }}
    {{ blacklist_vps() }}

    errorfile               403 /etc/haproxy-ddos/errors/403-html.http
    rspidel ^Server:.*$
    option httpchk GET /ping HTTP/1.1\r\nHost:\ 127.0.0.1
    http-check expect status 200

    server appbackend 10.0.0.2:3000 check inter 1000 rise 1 fall 2

    # For example: run a local 'maintenance mode' server on 3000 - this will be used when all backends are down
    # server local-maintenance localhost:3000 check inter 1000 backup

backend api
    errorfile               403 /etc/haproxy-ddos/errors/403-json.http
    rspidel ^Server:.*$
    option httpchk GET /ping HTTP/1.1\r\nHost:\ 127.0.0.1
    http-check expect status 200

    server apibackend 10.0.0.2:4000 check inter 1000 rise 1 fall 2