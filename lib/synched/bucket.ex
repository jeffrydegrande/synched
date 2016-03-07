defmodule Synched.Bucket do
  def start_link() do
    Agent.start_link(fn -> :no_value end)
  end

  @doc "Retrieves the state of the agent or updates it by calling a function" 
  def get(bucket, func) do
    Agent.get_and_update(bucket, fn state ->
      case state do
        :no_value ->
          new_state = func.()
          {new_state, new_state}
        ^state ->
          {state, state}
      end
    end)
  end

  @doc "Overwrites the state of the agent"
  def put(bucket, func) do
    Agent.update(bucket, fn x -> func.() end)
  end
end
