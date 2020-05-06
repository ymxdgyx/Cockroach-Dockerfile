# Cockroach-Centos-Docker

### 1. Install cockroachDB
```
wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.1.src.tgz | tar xvz
cd cockroach-v19.1.1
make build
sudo make install
```

```
mkdir ~/cockroachdb
export GOPATH=~/cockroachdb/
mkdir -p $(go env GOPATH)/src/github.com/cockroachdb
cd $(go env GOPATH)/src/github.com/cockroachdb
git clone git@github.com:cockroachdb/cockroach.git   
cd cockroach
make build
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
```
docker build -t cockroach-centos-docker:0.1 .
```

### 5. DockerHub link
https://hub.docker.com/r/ymxdgyx/cockroach-centos-docker
