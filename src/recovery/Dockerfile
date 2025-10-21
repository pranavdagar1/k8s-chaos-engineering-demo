# 1️⃣ Base image
FROM node:18-alpine

# 2️⃣ Set working directory inside the container
WORKDIR /usr/src/app

# 3️⃣ Copy package files first (for dependency caching)
COPY package*.json ./

# 4️⃣ Install dependencies
RUN npm ci --only=production

# 5️⃣ Copy the rest of the app code
COPY . .

# 6️⃣ Expose the port the app runs on
EXPOSE 5000

# 7️⃣ Define the command to run the app
CMD ["node", "index.js"]
