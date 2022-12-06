defmodule FormAnswers do
  def get_answers_stream() do
    File.stream!("./input/6.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
  end

  def get_answers_frequencies(answers_list) do
    answers_list
    |> Enum.reduce(%{}, fn answers, acc ->
      char_freqs = answers |> String.graphemes() |> Enum.frequencies()

      Map.merge(acc, char_freqs, fn _k, v1, v2 ->
        v1 + v2
      end)
    end)
  end

  def count_unique_answers() do
    get_answers_stream()
    |> Enum.map(&get_answers_frequencies(&1))
    |> Enum.map(&map_size(&1))
    |> Enum.sum()
  end

  def count_common_answers() do
    get_answers_stream()
    |> Enum.map(fn (answers_list) ->
      ans_freqs = get_answers_frequencies(answers_list)
      num_people = length(answers_list)
      Map.values(ans_freqs)
      |> Enum.count(&(&1 == num_people))
    end)
    |> Enum.sum()
  end
end
