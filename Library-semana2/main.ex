defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: [], borrow_history: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book], borrow_history: user.borrow_history ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def books_by_author(library, author) do
    Enum.filter(library, fn book -> book.author == author end)
  end

  def borrow_history(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrow_history, else: []
  end

  def run(library \\ [], users \\ []) do
    IO.puts("Bienvenido a la Biblioteca")

    loop(library, users)
  end

  defp loop(library, users) do
    IO.puts("""

    Opciones:

    1- Agregar un libro
    2- Agregar un usuario
    3- Prestar un libro
    4- Devolver un libro
    5- Listar libros
    6- Listar libros por autor
    7- Listar usuarios
    8- Listar libros prestados por usuario
    9- Consultar historial de libros prestados por usuario
    10- Salir

    """)

    case IO.gets("Opción: ") |> String.trim() |> String.to_integer() do
      1 ->
        title = IO.gets("Título del libro: ") |> String.trim()
        author = IO.gets("Autor del libro: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()

        book = %Book{title: title, author: author, isbn: isbn}
        library = add_book(library, book)

        loop(library, users)

      2 ->
        name = IO.gets("Nombre del usuario: ") |> String.trim()
        id = IO.gets("ID del usuario: ") |> String.trim()

        user = %User{name: name, id: id}
        users = add_user(users, user)

        loop(library, users)

      3 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()

        case borrow_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            IO.puts("Libro prestado exitosamente")
            loop(updated_library, updated_users)
          {:error, msg} ->
            IO.puts(msg)
            loop(library, users)
        end

      4 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()

        case return_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            IO.puts("Libro devuelto exitosamente")
            loop(updated_library, updated_users)
          {:error, msg} ->
            IO.puts(msg)
            loop(library, users)
        end

      5 ->
        IO.puts("Libros en la biblioteca:")
        list_books(library)
        |> Enum.each(&IO.puts("#{&1.title} por #{&1.author}, ISBN: #{&1.isbn}, Disponible: #{&1.available}"))

        loop(library, users)

      6 ->
          author = IO.gets("Autor del libro: ") |> String.trim()

          IO.puts("Libros por el autor #{author}:")
          books_by_author(library, author)
          |> Enum.each(&IO.puts("#{&1.title}, ISBN: #{&1.isbn}, Disponible: #{&1.available}"))

          loop(library, users)

      7 ->
        IO.puts("Usuarios en la biblioteca:")
        list_users(users)
        |> Enum.each(&IO.puts("#{&1.name}, ID: #{&1.id}"))

        loop(library, users)

      8 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()

        IO.puts("Libros prestados por el usuario:")
        books_borrowed_by_user(users, user_id)
        |> Enum.each(&IO.puts("#{&1.title} por #{&1.author}, ISBN: #{&1.isbn}"))

        loop(library, users)

      9 ->
          user_id = IO.gets("ID del usuario: ") |> String.trim()

          IO.puts("Historial de libros prestados por el usuario:")
          borrow_history(users, user_id)
          |> Enum.each(&IO.puts("#{&1.title} por #{&1.author}, ISBN: #{&1.isbn}"))

          loop(library, users)

      10 ->
        IO.puts("Chao y gracias")
        :ok

      _ ->
        IO.puts("Opción no válida, intente de nuevo.")
        loop(library, users)
    end
  end
end

Library.run()
