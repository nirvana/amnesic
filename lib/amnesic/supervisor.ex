defmodule Amnesic.Supervisor do
  use Supervisor.Behaviour

  def start_link(caches) do
    :supervisor.start_link(__MODULE__, caches)
  end

  def init(caches) do
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Amnesic.Worker, [])
      worker(Amnesic.Server, [caches])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise children, strategy: :one_for_one
  end
end
