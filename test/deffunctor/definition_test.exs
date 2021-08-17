defmodule Deffunctor.DefinitionTest do
  use ExUnit.Case

  alias Deffunctor.Definition

  describe "decompose/2" do
    test "decomposes the definition with no aliases and no submodules" do
      definition =
        quote do
          TheModule.(attribute)
        end

      assert Definition.decompose(definition, __ENV__) ==
               %Definition{name: TheModule, attrs: [{:attribute, [], __MODULE__}]}
    end

    test "decomposes the definition with no aliases and with submodules" do
      definition =
        quote do
          TheModule.Submodule.(attribute)
        end

      assert Definition.decompose(definition, __ENV__) ==
               %Definition{
                 name: TheModule.Submodule,
                 attrs: [{:attribute, [], __MODULE__}]
               }
    end

    test "decomposes the definition with aliases and without submodules" do
      alias Base.TheModule

      definition =
        quote do
          TheModule.(attribute)
        end

      assert Definition.decompose(definition, __ENV__) ==
               %Definition{
                 name: Base.TheModule,
                 attrs: [{:attribute, [], __MODULE__}]
               }
    end

    test "decomposes the definition with aliases and submodules" do
      alias Base.TheModule

      definition =
        quote do
          TheModule.Submodule.(attribute)
        end

      assert Definition.decompose(definition, __ENV__) ==
               %Definition{
                 name: Base.TheModule.Submodule,
                 attrs: [{:attribute, [], __MODULE__}]
               }
    end

    test "decomposes the definition with multiple attributes" do
      definition =
        quote do
          TheModule.(attr1, attr2)
        end

      assert Definition.decompose(definition, __ENV__) ==
               %Definition{
                 name: TheModule,
                 attrs: [{:attr1, [], __MODULE__}, {:attr2, [], __MODULE__}]
               }
    end

    test "returns an error when there were no attributes provided" do
      definition =
        quote do
          TheModule.()
        end

      assert_raise ArgumentError, "functor must have at least one attribute", fn ->
        Definition.decompose(definition, __ENV__)
      end
    end

    test "returns an error when attributes were ommited completely" do
      definition =
        quote do
          TheModule
        end

      assert_raise SyntaxError, fn ->
        Definition.decompose(definition, __ENV__)
      end
    end
  end

  describe "replace_attrs/3" do
    test "substitutes the attributes regardles of line number" do
      definition = %Definition{name: TheModule, attrs: [quote(do: x)]}

      body =
        quote do
          def f, do: x.f()
        end

      attrs = [quote(do: TheModule)]

      result =
        quote do
          def f, do: TheModule.f()
        end

      assert Definition.replace_attrs(definition, body, attrs) == result
    end
  end

  describe "wrap_body_in_module/3" do
    test "creates unique module name" do
      module = TheModule
      attrs = [quote(do: Module1), quote(do: 2)]

      body =
        quote do
          def f, do: module.(value)
        end

      assert {:defmodule, _, [module_name | _]} =
               Definition.wrap_body_in_module(module, attrs, body)

      assert module_name ==
               TheModule.InstanceCE539BD2FEFD5A41338BBE32A3E68F0E2FB2DECE15CCD90A4E36B925
    end
  end
end
