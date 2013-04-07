**Amnesic**
=======
_Members check in, but they don't check out._

The Forgetful Cache.  

**Amnesic** provides a cache-mediated database layer for highly read data.

### Status:  Under active development. Not usable yet.

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

All access to the cache and to the database are done in the scope of the calling 
process.  This is a library, not an applicaiton. 

During development of a custom version of this, ConCache [https://github.com/sasa1977/con_cache] 
was released, and so Amnesic is essentialy a wrapper around ConCache with access
to the database provided by Couchie. 

### Usage

API TBD
	
### Performance

Not yet tested.  However, an in-memory ETS should always be faster than a database 
request over the network.

