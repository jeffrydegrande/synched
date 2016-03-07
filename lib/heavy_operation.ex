defmodule HeavyOperation do
  def do_work(seconds \\ 1) do
    :timer.sleep(seconds * 1000)
    :random.uniform(100)
  end
end
