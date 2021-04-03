defmodule ExParserSample do
  @moduledoc false

  def item(<<>>), do: []

  def item(<<head::utf8, tail::binary>>), do: [{<<head>>, tail}]

  def failure(_), do: []

  def parse(parser), do: fn input -> parser.(input) end

  def concat(parser1, parser2) do
    fn input ->
      case parse(parser1).(input) do
        [] -> parse(parser2).(input)
        [{v, out}] -> [{v, out}]
      end
    end
  end

  def return(v), do: fn input -> [{v, input}] end

  @doc """
      iex> import ExParserSample
      iex> parser =
      ...>   bind(string("123"), fn x ->
      ...>     bind(string("abc"), fn _ ->
      ...>       bind(string("456"), fn z ->
      ...>         return(x <> z)
      ...>       end)
      ...>     end)
      ...>   end)
      iex> parser.("123abc456")
      [{"123456", ""}]
      iex> parser.("123def456")
      []
  """
  def bind(parser, f) do
    fn input ->
      case parse(parser).(input) do
        [] -> []
        [{v, out}] -> parse(f.(v)).(out)
      end
    end
  end

  def satisfies(predicate) do
    bind(&item/1, fn v ->
      if predicate.(v) do
        return(v)
      else
        &failure/1
      end
    end)
  end

  def char(c), do: satisfies(&(c == &1))

  def string(<<>>), do: return("")

  def string(<<head::utf8, tail::binary>>) do
    bind(char(<<head>>), fn _ ->
      bind(string(tail), fn _ ->
        return(<<head>> <> tail)
      end)
    end)
  end

  def many(parser) do
    concat(plus(parser), return(""))
  end

  def plus(parser) do
    bind(parser, fn v ->
      bind(many(parser), fn vs ->
        return(v <> vs)
      end)
    end)
  end

  def space do
    parser = many(satisfies(&(" " == &1)))
    bind(parser, fn _ -> return("") end)
  end

  def token(parser) do
    bind(&space/0, fn _ ->
      bind(parser, fn v ->
        bind(&space/0, fn _ ->
          return(v)
        end)
      end)
    end)
  end
end
