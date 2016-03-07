defmodule Synched do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Synched.Endpoint, []),
      supervisor(Synched.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Synched.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Synched.Endpoint.config_change(changed, removed)
    :ok
  end

  def exec(name, _timeout \\ 3600, func) do
    registry = Synched.Registry
    bucket = case Synched.Registry.lookup(registry, name) do
        :error        -> Synched.Registry.create(registry, name)
        {:ok, bucket} -> bucket
      end

    # should we trigger an update here?
    Synched.Bucket.get(bucket, func) 
  end
end
