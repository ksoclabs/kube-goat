FROM redis:5.0.4
# add startup script
RUN apt-get update && apt-get install -y procps
COPY ./init_redis.sh /init_redis.sh
COPY ./data.txt /data.txt
RUN chmod a+x /init_redis.sh