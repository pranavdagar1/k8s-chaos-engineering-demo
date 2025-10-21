# 1️⃣ Use official Node.js runtime
FROM node:18-alpine

# 2️⃣ Set working directory inside the container
WORKDIR /usr/src/app

# 3️⃣ Copy package.json and package-lock.json first for caching
COPY package*.json ./

# 4️⃣ Install production dependencies
RUN npm ci --only=production

# 5️⃣ Copy the rest of the app code
COPY . .

# 6️⃣ Expose the port the monitoring app will run on
EXPOSE 4000

# 7️⃣ Command to run the app
CMD ["node", "index.js"]
