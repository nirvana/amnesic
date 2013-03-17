**amnesic**
=======
_Members check in, but they don't check out._

The Forgetful Cache.  Simple elixir cache that ejects members before too long.

**amnesic** maintains an in memory table (probably HashDict backed by ETS) of key/value pairs. 
When started, amnesic needs to know how good of a memory to have. Given this figure, it 
spawns a process that periodically goes thru the table and cleans out any member that 
was there during its last run. 

It's meant that you use this for data that doesn't change very often (and its ok if it is out 
of date as much as the length of the timer you set up), but that is read very often, to 
minimize hitting a more resource intensive answer to your query.  

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
	


#### RDD - Readme Driven Development

TODO:
-- Implement start to set up tables, maintain a record of existing tables.
-- Implement get and set
-- Make process that goes Enums over each table, checking each record. Each record has a field
-- Support multiple named caches.
