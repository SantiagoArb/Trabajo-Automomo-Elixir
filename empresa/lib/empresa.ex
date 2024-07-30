defmodule Empresa do
  @moduledoc """
  This module contains the Employee struct and related functions.

  ## Special Symbols
  - `defmodule`: Defines a new module
  - `@moduledoc`: Provides documentation for the module
  """

  defmodule Employee do
    @moduledoc """
    Defines the Employee struct with common attributes.

    ## Special Symbols
    - `defmodule`: Defines a nested module
    - `@moduledoc`: Provides documentation for the module
    - `@enforce_keys`: Specifies which keys must be set when creating a new struct
    - `defstruct`: Defines a struct with the specified fields
    - `@type`: Defines a custom type for the struct
    """

    @enforce_keys [:name, :position]
    @derive {Jason.Encoder, only: [:id, :name, :position, :email, :phone, :hire_date, :salary]}
    defstruct [:id, :name, :position, :email, :phone, :hire_date, :salary]

    @type t :: %__MODULE__{
      id: integer() | nil,
      name: String.t(),
      position: String.t(),
      email: String.t() | nil,
      phone: String.t() | nil,
      hire_date: Date.t() | nil,
      salary: float() | nil
    }

    @doc """
    Creates a new Employee struct.

    ## Parameters
    - `name`: String, the employee's name (required)
    - `position`: String, the employee's job position (required)
    - `opts`: Keyword list of optional attributes (optional)

    ## Returns
    - `%Empresa.Employee{}`: A new Employee struct

    ## Special Symbols
    - `@doc`: Provides documentation for the function
    - `def`: Defines a public function
    - `\\\\`: Default argument separator
    - `__MODULE__`: Refers to the current module
    - `!`: In `struct!`, raises an error if required keys are missing

    ## Examples
        iex> Empresa.Employee.new("John Doe", "Developer")
        %Empresa.Employee{name: "John Doe", position: "Developer"}
    """
    def new(name, position, opts \\ []) do
      struct!(__MODULE__, [name: name, position: position] ++ opts)
    end
  end
end
