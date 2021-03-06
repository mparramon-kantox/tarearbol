defmodule Tarearbol do
  @moduledoc """
  `Tarearbol` module provides an interface to run tasks in easy way.

  ## Examples

      iex> result = Tarearbol.ensure(fn -> raise "¡?" end, attempts: 1, raise: false)
      iex> {:error, %{job: _job, outcome: outcome}} = result
      iex> {error, _stacktrace} = outcome
      iex> error
      %RuntimeError{message: "¡?"}
  """

  @spec ensure((Function.t | {Module.t, Atom.t, List.t}), Keyword.t) :: ({:error, any} | {:ok, any})
  def ensure(job, opts \\ []), do: Tarearbol.Job.ensure(job, opts)
  @spec ensure!((Function.t | {Module.t, Atom.t, List.t}), Keyword.t) :: ({:error, any} | {:ok, any})
  def ensure!(job, opts \\ []), do: Tarearbol.Job.ensure!(job, opts)

  @spec ensure_all_streamed([Function.t | {Module.t, Atom.t, List.t}], Keyword.t) :: [Stream.t]
  def ensure_all_streamed(jobs, opts \\ []), do: Tarearbol.Jobs.ensure_all_streamed(jobs, opts)
  @spec ensure_all([Function.t | {Module.t, Atom.t, List.t}], Keyword.t) :: [{:error, any} | {:ok, any}]
  def ensure_all(jobs, opts \\ []), do: Tarearbol.Jobs.ensure_all(jobs, opts)

  @spec run_in((Function.t | {Module.t, Atom.t, List.t}), (Atom.t | Integer.t | Float.t), Keyword.t) :: Task.t
  def run_in(job, interval, opts \\ []), do: Tarearbol.Errand.run_in(job, interval, opts)
  @spec run_at((Function.t | {Module.t, Atom.t, List.t}), (DateTime.t | String.t), Keyword.t) :: Task.t
  def run_at(job, at, opts \\ []), do: Tarearbol.Errand.run_at(job, at, opts)
  @spec spawn((Function.t | {Module.t, Atom.t, List.t}), Keyword.t) :: Task.t
  def spawn(job, opts \\ []), do: Tarearbol.Errand.spawn(job, opts)

  @spec drain() :: [{:error, any} | {:ok, any}]
  def drain() do
    jobs = Tarearbol.Application.jobs
    Tarearbol.Application.kill()
    for {job, opts, _at} <- jobs, do: Tarearbol.ensure(job, opts)
  end
end
