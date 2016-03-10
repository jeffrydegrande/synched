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
  
  def put(bucket, func, ttl \\ 0) do
    GenServer.call(bucket, {:put, func, ttl})
  end

  def schedule_refresh(ttl) do
    if ttl > 0 do
      Process.send_after(self(), :refresh, ttl)
    end
  end

  def handle_call({:get, new_func, ttl}, _from, {value, func} = state) do
    case state do
      {:no_value, _} ->
        new_value = new_func.()
        schedule_refresh(ttl)
        {:reply, new_value, {new_value, new_func}}

      {^value, _} ->
        {:reply, value, state}
    end
  end

  def handle_call({:put, func, ttl}, _from, state) do
    new_value = func.()
    schedule_refresh(ttl)
    {:reply, new_value, {new_value, func}}
  end

  def handle_info(:refresh, {value, func}) do
    # schedule_refresh(ttl)
    {:noreply, {func.(), func}}
  end
end
