See [this thread](https://teams.microsoft.com/l/message/19:264c78fefa624bcfaf46ac10b9305f5e@thread.skype/1637081341822?tenantId=0693b5ba-4b18-4d7b-9341-f32f400a5494&groupId=2651eb2e-8cf1-4caa-a084-0a11facc1d36&parentMessageId=1637081341822&teamName=GS-WMA%20IIDD%20Staff&channelName=Function%20-%20Data%20Pipelines&createdTime=1637081341822). Use shifter.

Michael Meyer has experimented with this using `future.batchtools` and run into trouble, detailed in thread above; there's a thread somewhere between him and Will Landau. The `targets_kamiak` folder contains Michael Meyer's group's attempt to do this at UWisc. I have seen in other threads that Landau seems to recommend/prefer `clustermq`.

# ClusterMQ
ClusterMQ is not installed on denali.

## ZeroMQ
ZeroMQ is not installed on denali. Did my own installation from [source](https://github.com/zeromq/libzmq/tree/v4.3.4):

```bash
git clone git@github.com:zeromq/libzmq.git
cd libzmq
./autogen.sh
./configure --prefix=/home/jross/zeromq
make
make install
```

**To try: install from a tagged version or download a tarball instead of just building from master**

## Install ClusterMQ
```bash
module cray-R
LD_LIBRARY_PATH=/home/jross/zeromq/lib R
```

```r
install.packages("clustermq")
```
