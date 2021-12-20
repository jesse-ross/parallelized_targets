See [this thread](https://teams.microsoft.com/l/message/19:264c78fefa624bcfaf46ac10b9305f5e@thread.skype/1637081341822?tenantId=0693b5ba-4b18-4d7b-9341-f32f400a5494&groupId=2651eb2e-8cf1-4caa-a084-0a11facc1d36&parentMessageId=1637081341822&teamName=GS-WMA%20IIDD%20Staff&channelName=Function%20-%20Data%20Pipelines&createdTime=1637081341822). Use shifter.

Michael Meyer has experimented with this using `future.batchtools` and run into trouble, detailed in thread above; there's a thread somewhere between him and Will Landau. The `targets_kamiak` folder contains Michael Meyer's group's attempt to do this at UWisc. I have seen in other threads that Landau seems to recommend/prefer `clustermq`.

# ClusterMQ Installation
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

## Set up Environment

In `~/.Rprofile`:

```r
options(
    clustermq.scheduler = "slurm",
    clustermq.template = "~/.clustermq.template" # following instructions at https://mschubert.github.io/clustermq/articles/userguide.html
)
```

In `~/.clustermq.template`:

```bash
#!/bin/sh
#SBATCH --job-name={{ job_name }}
#SBATCH --partition=workq
#SBATCH --output={{ log_file | /dev/null }} # you can add .%a for array index
#SBATCH --error={{ log_file | /dev/null }}
#SBATCH --mem-per-cpu={{ memory | 4096 }}
#SBATCH --array=1-{{ n_jobs }}
#SBATCH --cpus-per-task={{ cores | 1 }}
#SBATCH --account=iidd

ulimit -v $(( 1024 * {{ memory | 4096 }} ))
CMQ_AUTH={{ auth }} R --no-save --no-restore -e 'clustermq:::worker("{{ master }}")'
```

# Testing ClusterMQ

```bash
sbatch test_clustermq_submission.slurm
```

This sources a simple R script to do a parallelized `foreach`.  However, it is failing with an enigmatic error:

```bash
jross@denali-login2:~> cat test_slurm_submission.out
Fri Dec 17 16:30:45 2021: [unset]:_pmi_alps_init:alps_get_placement_info returned with error -1
Fri Dec 17 16:30:45 2021: [unset]:_pmi_init:_pmi_alps_init returned -1
```

# Backing off of Direct Use of ClusterMQ on Denali

The need for custom installation is janky and in any case it looks as though targets doesn't support containerization for this kind of parallelization [citation needed]. Since each node on denali has 80 cores, we should be able to run a lot of parallel jobs within a single container. So my current idea is to build out within-container local parallelization, and then run a shifter container on a node to do the work.

## Things to improve/fix
* Dockerfile reorganization to make most-likely-to-change things first
* Better way to add the `.Rprofile`?
* `multicore` won't work well in certain circumstances like RStudio or on Windows - probably better to target working on users' own machines with `multisession`, even though it costs more RAM.
* Get a better understanding of how `Q(n_jobs = x)` works when `x` is greater than the number of cores.
