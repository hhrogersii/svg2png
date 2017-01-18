#https://hub.docker.com/r/wernight/phantomjs/
FROM wernight/phantomjs
COPY service.js /
COPY resources /resources/
CMD ["phantomjs", "service.js"]
EXPOSE 8910
