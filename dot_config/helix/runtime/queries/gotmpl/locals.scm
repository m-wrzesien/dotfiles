; TODO: Remove this after relase of version containing https://github.com/helix-editor/helix/pull/14746
[
  (if_action)
  (range_action)
  (block_action)
  (with_action)
  (define_action)
] @local.scope

(variable_definition
  variable: (variable) @local.definition.variable)

(variable) @local.reference

