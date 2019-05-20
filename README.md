# Readers Writer Lock

[![Build Status](https://travis-ci.org/spider-gazelle/readers-writer.svg?branch=master)](https://travis-ci.org/spider-gazelle/readers-writer)

Allows any number of concurrent readers, but only one concurrent writer (And while the "write" lock is taken, no read locks can be obtained either)


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     rwlock:
       github: spider-gazelle/readers-writer
   ```

2. Run `shards install`

## Usage

```crystal
require "rwlock"

balance = 10
rwlock = RWLock.new

# Reading the balance
rwlock.read { puts balance.inspect }

# Modifying
rwlock.write { balance += 10 }
rwlock.synchronize { balance += 10 }

```
