# ExParserSample

パーサーコンビネーターのサンプル

まだ実装中…

```elixir
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
```
