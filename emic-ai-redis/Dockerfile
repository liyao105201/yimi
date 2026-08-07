FROM redis:7.0.0
ARG VERSION=2.2
MAINTAINER EMI-AI "Copyright © 2018 EMI. ALL rights reserved"
ADD ./src/redis.conf /etc/pbx/redis/redis.conf.orgin
ADD ./src/script /etc/pbx/script
RUN chmod +x /etc/pbx/script/*.sh
ENTRYPOINT ["/etc/pbx/script/docker-entrypoint.sh"]
CMD [ "sh", "/etc/pbx/script/start-product.sh"]