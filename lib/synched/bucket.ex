defmodule Synched.Bucket do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:ok, {:no_value, nil, 0}}
  end

  def get(bucket, func, ttl \\ 0) do
    GenServer.call(bucket, {:get, func, ttl}, 60_000)
  end
  
  def put(bucket, func, ttl \\ 0) do
    GenServer.call(bucket, {:put, func, ttl}, 60_000)
  end

  def schedule_refresh(ttl) do
    if ttl > 0 do
      Process.send_after(self(), :refresh, ttl)
    end
  end

  def handle_call({:get, new_func, new_ttl}, _from, {value, _, _} = state) do
    case state do
      {:no_value, _, _} ->
        new_value = check_arity_and_call(new_func, value)
        schedule_refresh(new_ttl)
        {:reply, new_value, {new_value, new_func, new_ttl}}

      {^value, _, _} ->
        # TODO: probably should allow the ttl to be set which would allow a manual
        # expire
        {:reply, value, state}
    end
  end

  def handle_call({:put, func, ttl}, _from, _state) do
    new_value = func.()
    schedule_refresh(ttl)
    {:reply, new_value, {new_value, func, ttl}}
  end

  def handle_info(:refresh, {value, func, ttl}) do
    schedule_refresh(ttl)
    {:noreply, {check_arity_and_call(func, value), func, ttl}}
  end

  def check_arity_and_call(func, value) do
    if is_function(func, 1) do
      func.(value)
    else
      func.()
    end
  end
end
