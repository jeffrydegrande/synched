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

  def schedule_refresh(ttl) do
    if ttl > 0 do
      Process.send_after(self(), :refresh, ttl)
    end
  end

  def handle_call({:get, func, ttl}, _from, state) do
    case state do
      {:no_value, _} ->
        new_value = func.()
        schedule_refresh(ttl)
        {:reply, new_value, {new_value, func}}

      {new_value, _} ->
        {:reply, new_value, {new_value, func}}
    end
  end

  def handle_call({:put, func}, _from, state) do
    new_value = func.()
    {:reply, new_value, {new_value, func}}
  end

  def handle_info(:refresh, {value, func, ttl}) do
    schedule_refresh(ttl)
    {:noreply, {func.(), func}}
  end
end
