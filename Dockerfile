FROM haproxy:alpine
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
EXPOSE 8083 8086
COPY run.sh /bin/

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/bin/sh", "/bin/run.sh"]
