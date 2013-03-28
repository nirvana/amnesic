**amnesic**
=======
_Members check in, but they don't check out._

The Forgetful Cache.  Simple elixir cache that ejects members before too long.

**amnesic** maintains an in memory table of key/value pairs.  When started, amnesic
needs to know how good of a memory to have. Given this figure, it spawns a process 
that periodically goes thru the table and cleans out any member that hasn't been 
requested since its last run. This is a simple form of LRU. It can also be set to
re-fetch items that have gotten stale, using a supplied callback. 

### Purpose

This is meant improve performance in situations where you're frequently fetching the 
same data from a database.  Presumably the database is on another machine, and reading
memory is vastly faster than going over the network.  Naturally, the data can get 
stale, and so even frequently requested data needs to be updated periodically.

Canonical example: Caching DNS records.  They change rarely, but are read a lot, and it's ok if
they are a few minutes out of date.

### Usage

**Amnesic.start(bucket, ttl)**

Sets up the bucket if it doesn't exist, if it does, sets the ttl.

**Amnesic.get(bucket, key, value)** 

See if Amnesic remembers a value, for given key, bucket. 
	
Returns 

{:remembered, Value}

{:forgot}

**Amnesic.set(bucket, key, value)**

Tell Amnesic about a value for a given key and bucket.

It will remember, for awhile.
	
### Performance

Not yet tested.

Looking at the performance of HashDict, it appears that integer keys are most performant, 
while string, binary and list keys are acceptable.  Everything is pretty fast up to about
100,000 items in the cache, at which point you're looking at potentially tens of milliseconds
of time to fetch a result, and it might be worthwhile to go over the network to the authoritative
data source, depending on how fast it is. 

#### RDD - Readme Driven Development

**TODO:**

0. Consider a redesign.  We can use CAS to know if a record has been updated. So, really there are two goals for this library:
 a. to keep from just continuously accumulating records that aren't being used - so purge records that haven't been requested in awhile.
 b. to refresh records that have been updated in the db, while keeping those that haven't around (since compilation is presumably heavy.)
 c. Not to overrun memory.
 
To accomplish both goals we:
 - give a table size at table creation. also give a 
 - record the item sizes as we fill the table.
 - spawn a process that does two things, 
 	a. one to load new items when there's an update (how do we do this when lively needs to process them? maybe we have a callback for compilation?)
 	b. one to go thru and check the total memory usage of the table, and decide what to purge. 
 - every time an item is requested, we update a timestamp so we can know how old it is (eg: this is a LRU cache.)


1. Implement start to set up tables, maintain a record of existing tables.

2. Implement get and set

3. Make process that goes Enums over each table, checking each record. Each record has a field

4. Support multiple named caches.

5. Suppport elixir callback that is passed the item that has been forgotten when it is forgotten.

6. Implement a touch API, so that code can remind us about items so we don't forget (do we need this?)

### License

Will be open source when its ready to be used by other people.  Until then, copyright 2013, all rights reserved.
