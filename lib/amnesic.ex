
defrecord AmnesicRecord, node: nil, time: 0, sq: 0


defmodule Amnesic do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, caches) do
    Amnesic.Supervisor.start_link(caches)
  end

TODO:
- Library function to open a new database (and set up its cache.)
- Library function to get an item.
- Library function to set an item
- Library function to delete an item from the DB and Cache
- Process that goes thru each cache and purges items that are past their retention date.

end
