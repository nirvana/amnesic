**Amnesic**
=======
_Members check in, but they don't check out._

The Forgetful Cache.  

**Amnesic** provides a cache-mediated database layer for highly read data.

### Purpose

This is meant improve performance in situations where you're frequently needing the 
same data from a database.  Presumably the database is on another machine, and reading
local memory is vastly faster than going over the network, even to a memcached instance.
Naturally, the data can get  stale, and so even frequently requested data needs to be 
updated periodically. **Amnesic** handles this by periodically forgetting things.

Canonical example: Caching DNS records.  They change rarely, but are read a lot, 
and it's ok if they are even a few minutes out of date.

### Implementation Details

**Amnesic** maintains an in memory table of key/value pairs.  When started, amnesic
needs to know how good of a memory to have.  It then uses this value to purge stale
items from the cache. 

This method ensures that any item read from the cache is at least as fresh as the
retention value, and that infrequently used items don't hang around in the cache.

This algorithm was chosen for its low complexity.  **amnesic** is meant as a read 
cache, not an in-memory database.  The goal here is to minimize network connections
to read data out of a database / memcached. 

All access is thru a single gen_server so this is a serialized bottleneck. However
because this gen_server *only* manages the cache, it is hoped it won't be a bottleneck.

Requests to the database on a cache miss, and writes to the db are all done in the
scope of the calling process.  Effectively, this is concurrent i/o & evented cache.

### Usage

API TBD
	
### Performance

Not yet tested.

Looking at the performance of HashDict, it appears that integer keys are most performant, 
while string, binary and list keys are acceptable.  Everything is pretty fast up to about
100,000 items in the cache, at which point you're looking at potentially tens of milliseconds
of time to fetch a result, and it might be worthwhile to go over the network to the authoritative
data source, depending on how fast it is. 
