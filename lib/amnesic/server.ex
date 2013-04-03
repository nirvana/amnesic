# CAS is the value returned by the DB, not currently used, but could be used in a LRU cache to check the DB to see if this item is stale.
# key is the key under which this item was stored
# value is the item (HashDict or other structure) that was stored under the key.
# time is the point at which the item was first inserted into the cache
defrecord AmnesicRecord, cas: nil, key: nil, value: nil, time: 0

# This is the datastructure of a cache. It is used to bundle up the parameters of the cache with the cache itself.
# Amnesic supports multiple simultaneous caches, which are represented by AmnesicCache records which are 
# stored in the state (which is itself a Dict) under the key of their name. 
# ttl: 0 means never expire. ttl is expressed in seconds
# data: HashDict that is the actual cache.
defrecord AmnesicCache, ttl: 30, cache: nil, name: nil

defmodule Amnesic.Server do
  use GenServer.Behaviour

  @doc """
  Creates cache if it doesn't exist, updates ttl if it does.
    """
  def handle_cast({ :cache, AmnesicCache[ttl: time, name: cache_name] }, state) do
      cache_record = Dict.get(state, cache_name, nil)
      if cache_record do  #Cache exists, so we're just updating the ttl.
        new_cache = cache_record.ttl(time)
      else  # cache does not exist, so we need to open db connection and create it.
        Couchie.open(cache_name)
        dict = HashDict.new
        new_cache = AmnesicCache[ttl: time, name: cache_name, cache: dict]
      end
      new_state = Dict.put(state, name, new_cache)
      { :noreply, new_state }
  end

  @doc """
  Gets item from cache, returns :error_not_found if it isn't there. :error_bad_cache if the cache doesn't exist.
    """
  def handle_call({:get, cache_name, key}, _from, state) do
      cache_record = Dict.get(state, cache_name, nil)
      if cache_record do
        arecord = Dict.get(cache_record.cache, key, nil)
        {:reply, arecord, state }
      else
        {:reply, :error_bad_cache state }
      end
  end
  
  @doc """
  Sets a value in the cache under a given key. (doesn't matter if it already exists.)
  Requires a full AmnesicRecord to be passed, with CAS and time already set.
    """
  def handle_cast({:set, cache_name, arecord=AmnesicRecord[]}, state) when is_record(arecord, AmnesicRecord)do

  WARNING: Stopped here, this is not correctly implemented!

      cache_record = Dict.get(state, cache_name, nil)
      if cache_record do  #Cache exists, so we're inserting the value.
        new_cache = Dict.put(cache_record.cache, arecord.key, arecord)
      new_state = Dict.put(state, name, new_cache)
        { :noreply, new_state }
      else  # cache does not exist, so we puts a warning, eventually will need to implement logging.
        ## BUGBUG: need logging for these failure modes.
        IO.puts "WARNING! Attempted to set value on cache #{cahce_name} that does not exist!"
        { :noreply, state }
      end
  end

TODO:
- Handler to set an item in the cache
- Handler to get a list of names of all the caches.
- Handler to get all keys & times from the cache (used in GC)
- Handler to delete items from cach (takes list of keys)
 

  @doc """
  Gets item from cache, returns :error_not_found if it isn't there. :error_bad_cache if the cache doesn't exist.
    """
  def handle_call({:get, cache, key}, _from, state) do
    { flake, new_state} = get(Flaky.time, state, base)
    { :reply, flake, new_state }
  end


  def handle_call(:get, _from, state) do
    { flake, new_state} = get(Flaky.time, state, 10)
    { :reply, flake, new_state }
  end



  # Matches when the calling time is the same as the state time. Incr. sq
  def get(time, FlakyState[time: time, node: node, sq: seq], base) do
    #IO.puts "Matches when the calling time is the same as the state time. Incr. sq"
    #IO.puts "Making new state"
    new_state = FlakyState.new(time: time, node: node, sq: (seq+1))
    #IO.puts "Generating flake"
    {gen_flake(new_state, base), new_state}
  end

  # Matches when the times are different, reset sq
  def get(newtime, FlakyState[time: time, node: node], base)  when newtime > time do
    #IO.puts "Matches when the times are different, reset sq"
    new_state = FlakyState.new(time: newtime, node: node, sq: 0)
    #IO.puts "Generating flake"
    {gen_flake(new_state, base), new_state}
  end 

  # Error when clock is running backwards
  def get(newtime, FlakyState[time: time], _) when newtime < time do
    {:error, :clock_running_backwards}
  end

  def gen_flake(FlakyState[time: time, node: node, sq: seq], base) do
    #IO.puts "Flake: time: #{time} node: #{node} seq: #{seq}"
    <<number::[integer, size(128)]>> = <<time::[integer, size(64)],node::[integer, size(48)],seq::[integer, size(16)]>>
    #IO.puts "Have a flake, converting to list..."
    nlist = Flaky.I2l.to_list(number, base)
    #IO.puts "Flake is a list now."
    list_to_binary(nlist)
  end

def handle_cast({ :push, new }, stack) do
    { :noreply, [new|stack] }
  end

  def start_link(state) do
      :gen_server.start_link({ :local, :amnesic }, __MODULE__, state, [])
  end

  def init(state) do
    { :ok, state }
  end


end