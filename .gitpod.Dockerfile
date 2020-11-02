FROM klakegg/hugo:0.68.3-ext-alpine

RUN addgroup -g 1000 hugo \
    && adduser -u 1000 -G hugo -s /bin/sh -D hugo 

USER hugo