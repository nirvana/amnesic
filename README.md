**Amnesic**
=======

The Forgetful Cache.  

**Amnesic** provides a cache-mediated database layer for highly read data.

### Status:  Working, not in production.

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

	$ iex -S mix
	iex(1)> acache = AmnesicCache.new
	AmnesicCache[cache: nil, ttl: 30000, ttl_check: 30000, callback: nil, name: nil, size: 100, host: 'localhost:8091', bucket: [], pass: []]
	iex(2)> cache = Amnesic.start(acache)
	AmnesicCache[cache: ConCache[ets: 81938, lock: {KeyBalancer,10,#PID<0.92.0>,#PID<0.93.0>,#PID<0.94.0>,#PID<0.95.0>,#PID<0.96.0>,#PID<0.97.0>,#PID<0.98.0>,#PID<0.99.0>,#PID<0.100.0>,#PID<0.101.0>}, ttl_manager: #PID<0.102.0>, ttl: 30000, acquire_lock_timeout: 5000, callback: nil, touch_on_read: false], ttl: 30000, ttl_check: 30000, callback: nil, name: nil, size: 100, host: 'localhost:8091', bucket: [], pass: []]
	iex(3)> value = Amnesic.get(cache, "4-2-13-5-12")
	Cache Miss
	AmnesicRecord[key: "4-2-13-5-12", cas: 17989975845485150208, value: ["d","e","f"], status: nil]
	iex(4)> Amnesic.set(cache, value)
	:ok
	iex(5)> next = AmnesicRecord[key: "4-7-13-6-17", value: ["test", "con_cache"]]
	AmnesicRecord[key: "4-7-13-6-17", cas: nil, value: ["test","con_cache"], status: nil]
	iex(6)> Amnesic.set(cache, next)
	:ok
	iex(7)> value = Amnesic.get(cache, "4-7-13-6-17")
	AmnesicRecord[key: "4-7-13-6-17", cas: nil, value: ["test","con_cache"], status: nil]

	... a few minutes later...
	iex(8)> value = Amnesic.get(cache, "4-7-13-6-17")
	Cache Miss
	AmnesicRecord[key: "4-7-13-6-17", cas: 10961573435125334016, value: ["test","con_cache"], status: nil]
	
### Performance

Not yet tested.  However, an in-memory ETS should always be faster than a database 
request over the network.


### Future Improvements

ConCache is configured with touch_on_read set to false.  This means that no matter how
frequently an item is read, it will expire in the cache after the TTL forcing an update
from the database, even though the item itself may be updated orders of magnitude less
frequently than the ttl.

A future improvement would be to set this to true, and spawn a background process to 
go thru the cache and compare the CAS of cached items with the database, updating them 
as they are changed on the DB side.  This would provide some improvement to performance
by reducing the periodic database reads further (and updating data in a seperate process,
rather than one that is answering a more important request.) It's not clear how much 
impact this would have in production, vs the increased complexity.
