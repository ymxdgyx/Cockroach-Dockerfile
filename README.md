# Cockroach-Centos-Docker

### 1. Install cockroachDB
```
wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.1.src.tgz | tar xvz
cd cockroach-v19.1.1
make build
sudo make install
```

### 2. Build from Source
https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html#build-from-source

### 3. Start DB
http://doc.cockroachchina.baidu.com/#quick-start/start-a-local-cluster/from-binary/

```
cockroach start --insecure --host=localhost
cockroach sql --insecure --port=26258
```
### 4. Build image
#### 4.1 Build image software
1. cmake-3.11.2.tar.gz  
2. go1.11.2.linux-amd64.tar.gz  

#### 4.2 Build command
```
docker build -t cockroach-centos-docker:0.1 .
```

### 5. DockerHub link
