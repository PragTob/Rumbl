defmodule Rumbl.InfoSys do
  @backends [Rumbl.InfoSys.Wolfram]

  defmodule Result do
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  @default_limit 10
  def compute(query, opts \\ []) do
    limit = opts[:limit] || @default_limit
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(fn (backend) -> spawn_query(backend, query, limit) end)
  end

  def spawn_query(backend, query, limit) do
    query_ref = make_ref
    opts = [backend, query, query_ref, self, limit]

    {:ok, pid} = Supervisor.start_child(Rumbl.InfoSys.Supervisor, opts)
    {pid, query_ref}
  end
end
