# *SAFE-DEOBS*

This repo contains scripts to reproduce the results in the paper "Optimizing
Away JavaScript Obfuscation".

## Requirements

* Bash
* GNU parallel
* Nodejs
* Scala
* Python `tabulate` package

## Usage

Clone the repo:

```bash
git clone --recursive https://github.com/DSTCyber/safe-deobs-evaluation.git
```

Build safe-deobs:

```bash
cd safe-deobs-evaluation/safe-deobs
export SAFE_HOME=$(pwd)
sbt compile
cd ..
```

Check which samples are parsable:

```bash
./01-parse.sh /path/to/output/dir
```

Normalize dataset:

```bash
./02-normalize.sh /path/to/output/dir
```

Remove duplicate files:

```bash
./03-dedup.sh /path/to/output/dir
```

Deobfuscate the samples:

```bash
./04-deob.sh /path/to/output/dir
```

Generate complexity reports:

```bash
./05-cr.sh /path/to/output/dir
```

Summarise complexity statistics:

```bash
./06-cr.py /path/to/output/dir
```
