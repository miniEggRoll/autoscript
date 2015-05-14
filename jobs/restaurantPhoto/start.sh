curl -o images.zip http://storage.googleapis.com/eztable-static/restaurant/images.zip
unzip images.zip
docker run -w="/app" -e NODE_ENV=dev -v `pwd`:/app node:0.12.2-wheezy bash -c "npm install && npm start"
rm -rf images
