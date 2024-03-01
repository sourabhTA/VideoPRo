module LetSupport
  # Poor man's let
  def let(var, &block)
    define_method(var) do
      instance_variable_get("@_memo_let_#{var}") || instance_variable_set("@_memo_let_#{var}", instance_eval(&block))
    end
  end
end
