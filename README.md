# Cockroach-Docker

### 1. Install cockroachDB
```
wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.0.src.tgz | tar xvz
cd cockroach-v19.1.0
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
#### NOTE: Go1.14+
```
make build IGNORE_GOVERS=1
```

#### NOTE: make building on ubuntu20.04 need to remove Werror option
```
src/github.com/cockroachdb/cockroach/c-deps/libroach/CMakeLists.txt +84 +172
src/github.com/cockroachdb/cockroach/c-deps/rocksdb/CMakeLists.txt +251
```

#### NOTE: make test for v19.1.0
```
go version : 1.12.17
```

### 2. Build from Source
https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux.html#build-from-source

### 3. Start DB
http://doc.cockroachchina.baidu.com/#quick-start/start-a-local-cluster/from-binary/

```
cockroach start --insecure --host=localhost
cockroach sql --insecure --port=26257
```
### 4. Build image  
```
docker build -t cockroach-centos-docker:0.1 -t cockroach-centos-docker:latest --build-arg osver=7 .
```

### 5. DockerHub link
https://hub.docker.com/r/ymxdgyx/cockroach-centos-docker

### 6. VScode debug cockroachDB
```
launch.json:
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "/home/drdb/cockroachdb/src/github.com/cockroachdb/cockroach/pkg/cmd/drdb/",
            "args": ["start","--insecure","--host=localhost"],
            // "showLog": true
        }
    ]
}
```
