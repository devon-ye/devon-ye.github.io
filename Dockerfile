# 第一阶段：构建
# 使用带有Node.js的镜像构建React应用
FROM node:latest as build

# 设置工作目录
WORKDIR /app

# 将package.json和package-lock.json复制到工作目录
COPY package*.json /app/

# 安装项目依赖
RUN npm install

# 复制项目文件到工作目录
COPY . /app

# 构建应用
RUN npm run build

# 第二阶段：部署
# 使用Nginx镜像
FROM nginx:alpine

# 将构建的静态文件复制到Nginx的服务目录
COPY --from=build /app/build/ /usr/share/nginx/html

# 替换Nginx的默认配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 暴露80端口
EXPOSE 80

# 启动Nginx服务器
CMD ["nginx", "-g", "daemon off;"]
