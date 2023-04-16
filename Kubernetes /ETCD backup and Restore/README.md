# ETCD Backup and Restore

## Question

Create a snapshot of the existing etcd instance running on https://127.0.0.1:2379 
and save the snapshot to /tmp/etcd-backup/etcd-snapshot.db

Restore the existing previous snapshot located at /tmp/etcd-backup/etcd-snapshot-previous.db

The following TLS certificates and keys are provided to connect to the server via etcdctl.

CA certificate: /tmp/etcd/ca.crt
Client certificate: /tmp/etcd/etcd-client.crt
Client key: /tmp/etcd/etcd-client.key


