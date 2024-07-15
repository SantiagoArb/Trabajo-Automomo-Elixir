defmodule InventoryManager do
  defstruct inventory: [], cart: [], next_id: 1

  def add_product(
        %InventoryManager{inventory: inventory, next_id: next_id} = state,
        name,
        price,
        stock
      ) do
    new_product = %{id: next_id, name: name, price: price, stock: stock}

    %{state | inventory: inventory ++ [new_product], next_id: next_id + 1}
  end

  def list_products(%InventoryManager{inventory: inventory}) do
    Enum.each(inventory, fn product ->
      IO.puts(
        "id: #{product.id}, Name: #{product.name}, Price: #{product.price}, Stock: #{product.stock}"
      )
    end)
  end

  def increase_stock(%InventoryManager{inventory: inventory} = state, id, quantity) do
    updated_inventory =
      Enum.map(inventory, fn product ->
        if product.id == id do
          %{product | stock: product.stock + quantity}
        else
          product
        end
      end)

    %{state | inventory: updated_inventory}
  end

  def sell_product(%InventoryManager{inventory: inventory, cart: cart} = state, id, quantity) do
    {product, updated_inventory} = Enum.split_with(inventory, fn product -> product.id == id end)

    if product != [] do
      [product] = product

      if product.stock >= quantity do
        updated_product = %{product | stock: product.stock - quantity}

        updated_cart = [{id, quantity} | cart]

        %{state | inventory: [updated_product | updated_inventory], cart: updated_cart}
      else
        IO.puts("No hay suficiente stock para el producto ID: #{id}")

        state
      end
    else
      IO.puts("Producto id: #{id} no encontrado.")

      state
    end
  end

  def view_cart(%InventoryManager{cart: cart, inventory: inventory}) do
    total =
      Enum.reduce(cart, 0, fn {id, quantity}, acc ->
        product = Enum.find(inventory, fn product -> product.id == id end)

        cost = product.price * quantity

        IO.puts("ID: #{id}, Name: #{product.name}, Quantity: #{quantity}, Total Cost: #{cost}")

        acc + cost
      end)

    IO.puts("Total a pagar: #{total}")
  end

  def checkout(%InventoryManager{cart: _cart} = state) do
    IO.puts("Checkout realizado. Gracias por su compra.")

    %{state | cart: []}
  end

  def run(state \\ %InventoryManager{}) do
    IO.puts("Bienvenido al Gestor de Inventario")

    loop(state)
  end

  defp loop(state) do
    IO.puts("""



    Opciones:

    1- Agregar un producto

    2- Listar productos

    3- Aumentar stock

    4- Vender producto

    5- Ver carrito

    6- Realizar checkout

    7- Salir

    """)

    case IO.gets("Opcion: ") |> String.trim() |> String.to_integer() do
      1 ->
        name = IO.gets("Nombre del producto: ") |> String.trim()

        price = IO.gets("Precio del producto: ") |> String.trim() |> String.to_float()

        stock = IO.gets("Stock del producto: ") |> String.trim() |> String.to_integer()

        state = add_product(state, name, price, stock)

        loop(state)

      2 ->
        list_products(state)

        loop(state)

      3 ->
        id = IO.gets("ID del producto: ") |> String.trim() |> String.to_integer()

        quantity = IO.gets("Cantidad a aumentar: ") |> String.trim() |> String.to_integer()

        state = increase_stock(state, id, quantity)

        loop(state)

      4 ->
        id = IO.gets("ID del producto: ") |> String.trim() |> String.to_integer()

        quantity = IO.gets("Cantidad a vender: ") |> String.trim() |> String.to_integer()

        state = sell_product(state, id, quantity)

        loop(state)

      5 ->
        view_cart(state)

        loop(state)

      6 ->
        state = checkout(state)

        loop(state)

      7 ->
        IO.puts("Chao y gracias")

        :ok

      _ ->
        IO.puts("Opcion no válida, intente de nuevo.")

        loop(state)
    end
  end
end

InventoryManager.run()
