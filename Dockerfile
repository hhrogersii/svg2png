#https://hub.docker.com/r/wernight/phantomjs/
FROM wernight/phantomjs
COPY service /
CMD ["phantomjs", "service.js"]
EXPOSE 8910
