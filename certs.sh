# Create CA
mkdir certs
cd certs/
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt

## Create certs for Kong cluster communication `(DP <-> CP)`
mkdir -p cluster-certs
cd cluster-certs

# For CP
openssl req -new -sha256 -keyout kong-cluster-cp.key -out kong-cluster-cp.csr -nodes -newkey rsa:2048 -subj "/CN=*.kong-cp-kong-cluster.kong-cp-sit.svc.cluster.local"
openssl x509 -req -in kong-cluster-cp.csr -CA ../ca.crt -CAkey ../ca.key -CAcreateserial -out kong-cluster-cp.crt -days 365 -sha256 -extfile <(printf "subjectAltName=DNS:kong-cp-kong-cluster.kong-cp-sit.svc.cluster.local,DNS:kong-cp-kong-clustertelemetry.kong-cp-sit.svc.cluster.local")
cat kong-cluster-cp.crt ../ca.crt > kong-cluster-cp-bundle.crt

# For DP
openssl req -new -sha256 -keyout kong-cluster-dp.key -out kong-cluster-dp.csr -nodes -newkey rsa:2048 -subj "/CN=*.kong-cp-kong-cluster.kong-cp-sit.svc.cluster.local"
openssl x509 -req -in kong-cluster-dp.csr -CA ../ca.crt -CAkey ../ca.key -CAcreateserial -out kong-cluster-dp.crt -days 365 -sha256 -extfile <(printf "subjectAltName=DNS:kong-cp-kong-cluster.kong-cp-sit.svc.cluster.local,DNS:kong-cp-kong-clustertelemetry.kong-cp-sit.svc.cluster.local")
cat kong-cluster-dp.crt ../ca.crt > kong-cluster-dp-bundle.crt

## Create certs for all management URLs (admin, manager, portal, portalcli)
cd ..
mkdir -p management-certs
cd management-certs

openssl req -new -sha256 -keyout kong-manage.key -out kong-manage.csr -nodes -newkey rsa:2048 -subj "/CN=*.example.com"
openssl x509 -req -in kong-manage.csr -CA ../ca.crt -CAkey ../ca.key -CAcreateserial -out kong-manage.crt -days 365 -sha256 -extfile <(printf "subjectAltName=DNS:*.example.com")
cat kong-manage.crt ../ca.crt > kong-manage-bundle.crt
