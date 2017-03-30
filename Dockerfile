#https://hub.docker.com/r/wernight/phantomjs/
FROM wernight/phantomjs
COPY service.js /
COPY resources /resources/
CMD ["phantomjs", "--web-security=false", "--local-to-remote-url-access=yes", "--ignore-ssl-errors=true", "service.js"]
EXPOSE 8910
