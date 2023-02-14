defmodule Identicon do
  def main(input) do
    input
    |> hashInput
    |> pickColor
    |> buildGrid
    |> filterOddSquares
    |> buildPixelMap
    |> drawImage
    |> saveImage(input)
  end

  def saveImage(image, input) do
    File.write("#{input}.png", image)
  end

  def drawImage(%Identicon.Image{color: color, pixelMap: pixelMap}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixelMap, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def buildPixelMap(image) do
    %Identicon.Image{grid: grid} = image

    pixelMap = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      topLeft = {horizontal, vertical}
      bottomRight = {horizontal + 50, vertical + 50}

      {topLeft, bottomRight}
    end

    %Identicon.Image{image | pixelMap: pixelMap}
  end

  def filterOddSquares(image) do
    %Identicon.Image{grid: grid} = image

    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def buildGrid(image) do
    %Identicon.Image{hex: hex} = image

    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirrorRow/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirrorRow(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  def pickColor(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image

    %Identicon.Image{image | color: {r, g, b}}
  end

  def hashInput(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
