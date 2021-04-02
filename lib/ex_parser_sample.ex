defmodule ExParserSample do
  @type parser :: (any -> any)
  @type result :: []

  @spec item(binary) :: result
  def item(<<>>), do: []

  def item(<<head::utf8, tail::binary>>), do: [{<<head>>, tail}]

  @spec failure(any) :: result
  def failure(_), do: []

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
  @spec parse(any) :: parser
  def parse(parser), do: fn input -> parser.(input) end

  @spec return(any) :: parser
  def return(v), do: fn input -> [{v, input}] end

  @spec bind(any, any) :: parser
  def bind(parser, f) do
    fn input ->
      case parse(parser).(input) do
        [] -> []
        [{v, out}] -> parse(f.(v)).(out)
      end
    end
  end

  @spec satisfies(any) :: parser
  def satisfies(predicate) do
    bind(&item/1, fn v ->
      if predicate.(v) do
        return(v)
      else
        &failure/1
      end
    end)
  end

  @spec char(any) :: parser
  def char(c), do: satisfies(&(c == &1))

  @spec string(binary) :: parser
  def string(<<>>), do: return([])

  def string(<<head::utf8, tail::binary>>) do
    char(<<head>>)
    |> bind(fn _ ->
      string(tail)
      |> bind(fn _ ->
        return(<<head>> <> tail)
      end)
    end)
  end
end
