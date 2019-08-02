defmodule Rit.CLI.Output do
  @moduledoc false

  def inform(information) do
    information
    |> parse()
    |> IO.puts()
  end

  def parse(information) when is_bitstring(information) do
    information
  end

  def parse(informations) when is_list(informations) do
    Enum.map_join(informations, " ", &parse/1)
  end

  def parse(information) when is_tuple(information) do
    parse(Tuple.to_list(information))
  end

  def parse(information) when is_nil(information) do
    ""
  end

  def parse(information) when is_atom(information) do
    information
    |> Atom.to_string()
    |> Recase.to_title()
  end
end
