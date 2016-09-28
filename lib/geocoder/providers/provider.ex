require IEx

defmodule Geocoder.Providers.Provider do
  use HTTPoison.Base

  ##############################################################################

  def go!(data, params \\ %Geocoder.QueryParams{}, provider \\ Geocoder.Worker.provider?)

  def go!(data, params, provider) when is_list(params) do #
    go!(data, %Geocoder.QueryParams{}, provider)
  end

  def go!(data, %Geocoder.QueryParams{} = params, provider) do # Geocoder.Worker.provider?
    data = if Keyword.keyword?(data), do: data[:address] || data[:latlng], else: data
    input = if Geocoder.Data.impl_for(data) == nil, do: apply(provider, :new, [data]), else: data
    params = Keyword.merge(
      Application.get_env(:geocoder, Geocoder.Worker)[:httpoison_options] || [],
      params: params |> Geocoder.QueryParams.to_map |> Map.merge(input |> Geocoder.Data.query |> Enum.into(%{}))
    )
    url = input |> Geocoder.Data.endpoint(:direct)

    case get(url, [], params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        result = body
                 |> Poison.decode!
                 |> Map.get("results")
                 |> List.first
        {:ok, apply(provider, :new, [result])}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  ##############################################################################

end
