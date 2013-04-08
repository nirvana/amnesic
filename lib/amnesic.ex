
#
#  Record that represents the cache & database
#  cache: The opaque value returned by con_cache used to refer to it in the future
#  ttl, ttl_check: expiry time and frequency of checking items in the cache
#  name: The name of the connection Couchie uses (to distinguish from multiple db connections)
#  size, host, bucket, pass: Couchie Parameters for accessing the database
#
defrecord AmnesicCache, cache: nil, ttl: :timer.seconds(30), ttl_check: :timer.seconds(30), 
          callback: nil, name: nil, size: 100, host: 'localhost:8091', bucket: '', pass: ''

#  Record that represents a value in the Cache
#  Key: used to identify the document in the cache and the database
#  cas: Couchbase value that lets us know whether the item has been changed since being cached
#  value: the actual record data in application format (eg: HashDict, not json)
#  status: used to indicate an error or other information? unused for now.
defrecord AmnesicRecord, key: nil, cas: nil, value: nil, status: nil

defmodule Amnesic do

  @doc """
    Returns: AmnesicCache or atom indicating error.
  - Start() - connection to default bucket on localhost
  - Start(AmnesicCache)
  - takes ttl and ttl_check frequency. Returns opaque value used to access in future.
  - takes db configuration and uses that to set up db connection. 

  """
  def start do
    start(AmnesicCache[name: :db])
  end
  
  def start(cache=AmnesicCache[]) do
    #options = Keyword.new [{}, {:ttl_check, cache[ttl_check]}, {:callback cache[callback]}]
    con_cache = ConCache.start_link(ttl: cache.ttl, ttl_check: cache.ttl_check, callback: cache.callback, touch_on_read: false)
    Couchie.open(cache.name, cache.size, cache.host, cache.bucket, cache.pass)
    cache.cache(con_cache)  # Return the AmnesicCache object with the Cache set to the ConCache record for our cache.
  end

  @doc """
    Returns: AmnesicRecord
    - Get:
      - Checks the cache, if found, returns, if not found, tries to fetch from the database, if successful, stores result in cache
  """
  def get(cache=AmnesicCache[], key) do
    case ConCache.get(cache.cache, key) do
      nil -> get_from_db(cache, key)
      value -> value 
    end
  end
  
  # Get the value from the database, if successful, update the cache.
  defp get_from_db(cache=AmnesicCache[], key) do
    #IO.puts "Cache Miss"
    {key, cas, value} = Couchie.get(cache.name, key)  # returns: {key, cas, value}
    record = AmnesicRecord[key: key, cas: cas, value: value]
    ConCache.put(cache.cache, key, record)
    record
  end

  @doc """
    Returns: 
    - Set: 
      - Stores result in cache, then stores it in the database.
  """
  def set(cache=AmnesicCache[], record=AmnesicRecord[]) do
    ConCache.put(cache.cache, record.key, record)
    Couchie.set(cache.name, record.key, record.value)
  end
  
end



