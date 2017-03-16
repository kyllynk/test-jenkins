FROM node:7.7.2

#Install PM2
RUN npm íntall -g pm2

#Create working directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

#Install dependencies
COPY package.json /usr/src/app
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 30000
CMD [ "npm", "start" ]