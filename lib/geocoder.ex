defmodule Geocoder do
  @moduledoc """
  Geocoder is a simple, efficient geocoder/reverse geocoder with a built-in cache support
  """
  alias Geocoder.Worker

  def call(opts) when is_list(opts), do: Worker.geocode(opts)

  def call(q, opts \\ [])
  def call(q, opts) when is_binary(q), do: Worker.geocode(opts ++ [address: q])

  def call({lat, lon} = q, opts),
    do: Worker.reverse_geocode(opts ++ [lat: lat, lon: lon, latlng: q])

  def call(%{lat: lat, lon: lon}, opts), do: call([latlng: {lat, lon}] ++ opts)

  def call_list(q, opts \\ [])
  def call_list(q, opts) when is_binary(q), do: Worker.geocode_list(opts ++ [address: q])
  def call_list({_, _} = q, opts), do: Worker.reverse_geocode_list(opts ++ [latlng: q])
end
