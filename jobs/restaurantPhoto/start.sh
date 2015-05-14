curl -o images.zip http://storage.googleapis.com/eztable-static/restaurant/images.zip
unzip images.zip
docker run -w="/app" -e NODE_ENV=dev -v `pwd`:/app node:0.12.2-wheezy \
    bash -c "apt-get update && apt-get install unzip && unzip images.zip && npm install && npm start"
rm -rf images
