defmodule TodoMvcWeb.TodoLive do
  use TodoMvcWeb, :live_view

  def mount(_params, _session, socket) do
    produtos = [
      %{id: "1", nome: "Amarula", quantidade: 0, preco_venda: 50.00, preco_custo: 30.00},
      %{id: "2", nome: "Ponche Cuba", quantidade: 5, preco_venda: 50.00, preco_custo: 30.00},
      %{
        id: Ecto.UUID.generate(),
        nome: "José Cuervo",
        quantidade: 3,
        preco_venda: 50.00,
        preco_custo: 30.00
      }
    ]

    socket =
      socket
      |> assign(:filter, "todos")
      |> assign(:produtos, produtos)
      |> assign(:filtered_produtos, produtos)

    {:ok, socket}
  end

  def handle_event("change_filter", %{"filter" => filter}, socket) do
    socket =
      socket
      |> assign(:filter, filter)
      |> filter_produtos()

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => idDelete}, socket) do
    socket =
      socket
      |> assign(:produtos, List.delete_at(socket.assigns.produtos,
          Enum.find_index(socket.assigns.produtos, fn produto ->
            produto.id == idDelete
          end)
      ))
      |> filter_produtos()

    {:noreply, socket}
  end

  def handle_event(
        "produto_form_submit",
        %{
          "new_produto" => %{
            "nome" => nome,
            "preco_venda" => preco_venda,
            "preco_custo" => preco_custo,
            "quantidade" => quantidade
          }
        },
        socket
      ) do
    {quantidadeInteger, _} = Integer.parse(quantidade)

    new_produto = %{
      id: Ecto.UUID.generate(),
      nome: nome,
      preco_venda: preco_venda,
      preco_custo: preco_custo,
      quantidade: quantidadeInteger
    }

    socket =
      socket
      |> assign(:produtos, [new_produto | socket.assigns.produtos])
      |> filter_produtos()

    # |> update_has_completed()
    # |> count_active()

    {:noreply, socket}
  end

  defp filter_produtos(socket) do
    socket
    |> assign(
      :filtered_produtos,
      Enum.filter(socket.assigns.produtos, fn produto ->
        case socket.assigns.filter do
          "todos" ->
            true

          "sem_estoque" ->
            produto.quantidade <= 0

          "estoque" ->
            produto.quantidade > 0
        end
      end)
    )
  end
end
