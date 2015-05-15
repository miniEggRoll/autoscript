docker run -w="/app" \
    -e NODE_ENV=dev \
    -e LC_SABRINA_HOST=`echo $LC_SABRINA_HOST` \
    -e LC_SABRINA_PORT=`echo $LC_SABRINA_PORT` \
    -e LC_SABRINA_USER=`echo $LC_SABRINA_USER` \
    -e LC_SABRINA_PASSWORD=`echo $LC_SABRINA_PASSWORD` \
    -v `pwd`:/app node:0.12.2-wheezy \
    bash -c "npm install && npm run th && npm run hk"
