defmodule Synched.Bucket do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:ok, {:no_value, nil}}
  end

  def get(bucket, func, ttl \\ 0) do
    GenServer.call(bucket, {:get, func, ttl})
  end
  
  def put(bucket, func) do
    GenServer.call(bucket, {:put, func})
  end

  def handle_call({:get, func, ttl}, _from, state) do
    case state do
      {:no_value, _} ->
        new_value = func.()
        # after a second we're going to update ourselves
        Process.send_after(self(), :refresh, 1000) 
        {:reply, new_value, {new_value, func}}
      {new_value, _} ->
        {:reply, new_value, {new_value, func}}
    end
  end

  def handle_call({:put, func}, _from, state) do
    new_value = func.()
    {:reply, new_value, {new_value, func}}
  end

  def handle_info(:refresh, {value, func}) do
    IO.puts "updating"
    Process.send_after(self(), :refresh, 1000) 
    {:noreply, {func.(), func}}
  end
end
