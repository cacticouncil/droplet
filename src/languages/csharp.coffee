# Droplet C# mode
#
# Copyright (c) 2018 Kevin Jessup
# MIT License
# Updated 2018 Kevin Wong

helper = require '../helper.coffee'
parser = require '../parser.coffee'
antlrHelper = require '../antlr.coffee'

model = require '../model.coffee'

{fixQuotedString, looseCUnescape, quoteAndCEscape} = helper


#▶
ADD_BUTTON = [
  {
    key: 'add-button'
    glyph: '\u25B6'
    border: false
  }
]

#◀
SUBTRACT_BUTTON = [
  {
    key: 'subtract-button'
    glyph: '\u25C0'
    border: false
  }
]

#◀▶
BOTH_BUTTON = [
  {
    key: 'subtract-button'
    glyph: '\u25C0'
    border: false
  }
  {
    key: 'add-button'
    glyph: '\u25B6'
    border: false
  }
]

#▼
ADD_BUTTON_VERT = [
  {
    key: 'add-button'
    glyph: '\u25BC'
    border: false
  }
]

#▲▼
BOTH_BUTTON_VERT = [
  {
    key: 'subtract-button'
    glyph: '\u25B2'
    border: false
  }
  {
    key: 'add-button'
    glyph: '\u25BC'
    border: false
  }
]

RULES = {
  # tell model to indent blocks within the main part of a 
  # namespace body (indent everything past namespace_member_declarations)
  'namespace_body': {
    'type': 'indent',
    'indexContext': 'namespace_member_declarations',
  },

  'class_body': {
    'type': 'indent',
    'indexContext': 'class_member_declarations',
  },

  'block': {
    'type' : 'indent',
    'indexContext': 'statement_list',
  },

  # Skips : no block for these elements
  'compilationUnit' : 'skip',
  'using_directives' : 'skip',
  'namespace_or_type_name' : 'skip',
  'namespace_member_declarations' : 'skip',
  'namespace_member_declaration' : 'skip',
  'class_definition' : 'skip',
  'class_member_declarations' : 'skip',
  'common_member_declaration' : 'skip',
  'constructor_declaration' : 'skip',
  'all_member_modifiers' : 'skip',
  'all_member_modifier' : 'skip',
  'qualified_identifier' : 'skip',
  'method_declaration' : 'skip',
  'method_body' : 'skip',
  'method_member_name' : 'skip',
  'variable_declarator' : 'skip',
  'variable_declarators' : 'skip',
  'var_type' : 'skip',
  'base_type' : 'skip',
  'class_type' : 'skip',
  'simple_type' : 'skip',
  'numeric_type' : 'skip',
  'integral_type' : 'skip',
  'floating_point_type' : 'skip',
  '=' : 'skip',
  'OPEN_PARENS' : 'skip',
  'CLOSE_PARENS' : 'skip',
  ';' : 'skip',
  'statement_list' : 'skip',
  'PARAMS' : 'skip',
  'array_type' : 'skip',
  'rank_specifier' : 'skip',
  'fixed_parameters' : 'skip',
  'fixed_parameter' : 'skip',
  'class_base' : 'skip',
  'local_variable_declarator' : 'skip',
  'embedded_statement' : 'skip',
  'member_access' : 'skip',
  'method_invocation' : 'skip',
  'bracket_expression' : 'skip',
  'indexer_argument' : 'skip',
  'NEW' : 'skip',
  'assignment' : 'skip',
  'generic_dimension_specifier' : 'skip',
  'unbound_type_name' : 'skip',
  'delegate_definition' : 'skip',
  'object_creation_expression' : 'skip',
  'argument' : 'skip',
  'argument_list' : 'skip',

  # Parens : defines nodes that can have parenthesis in them
  # (used to wrap parenthesis in a block with the
  # expression that is inside them, instead
  # of having the parenthesis be a block with a
  # socket that holds an expression)
  'primary_expression_start' : (node) ->
    if (node.children[0]?.type is 'NEW')
      return 'skip'
    else if (node.children[0]?.type is 'TYPEOF')
      return 'block'
    else
      return 'parens'

  # Sockets : can be used to enter inputs into a form or specify dropdowns
  'IDENTIFIER' : 'socket',
  'PUBLIC' : 'socket',
  'PROTECTED' : 'socket',
  'INTERNAL' : 'socket',
  'PRIVATE' : 'socket',
  'READONLY' : 'socket',
  'VOLATILE' : 'socket',
  'VIRTUAL' : 'socket',
  'SEALED' : 'socket',
  'OVERRIDE' : 'socket',
  'ABSTRACT' : 'socket',
  'STATIC' : 'socket',
  'UNSAFE' : 'socket',
  'EXTERN' : 'socket',
  'PARTIAL' : 'socket',
  'ASYNC' : 'socket',

  #Value Types
  'SBYTE' : 'socket',
  'BYTE' : 'socket',
  'SHORT' : 'socket',
  'USHORT' : 'socket',
  'INT' : 'socket',
  'UINT' : 'socket',
  'LONG' : 'socket',
  'ULONG' : 'socket',
  'CHAR' : 'socket',
  'FLOAT' : 'socket',
  'DOUBLE' : 'socket',
  'DECIMAL' : 'socket',
  'BOOL' : 'socket',

  'VOID' : 'socket',
  'VIRTUAL' : 'socket',

  #Literal Keywords
  'INTEGER_LITERAL' : 'socket',
  'HEX_INTEGER_LITERAL' : 'socket',
  'REAL_LITERAL' : 'socket',
  'CHARACTER_LITERAL' : 'socket',
  'NULL' : 'socket',
  'REGULAR_STRING' : 'socket',
  'VERBATIUM_STRING' : 'socket',
  'TRUE' : 'socket',
  'FALSE' : 'socket',

  # buttonContainer: defines a node that acts as
  # a "button" that can be placed inside of another block (these nodes generally should not
  # be able to be "by themselves", and wont be blocks if they are by themselves)
  # NOTE: the handleButton function in this file determines the behavior for what
  # happens when one of these buttons is pressed
  'formal_parameter_list' : (node) ->
    if (node.children[node.children?.length-1]?.type is 'parameter_array')
      return {type : 'buttonContainer', buttons : SUBTRACT_BUTTON}
    else
      if (node.children[0]?.children?.length == 1)
        return {type : 'buttonContainer', buttons : ADD_BUTTON}
      else
        return {type : 'buttonContainer', buttons : BOTH_BUTTON}

  'field_declaration' : (node) ->
    if (node.children[0]?.children?.length == 1)
      return {type : 'buttonContainer', buttons : ADD_BUTTON}
    else
      return {type : 'buttonContainer', buttons : BOTH_BUTTON}

  'local_variable_declaration' : (node) ->
    if (node.children?.length == 2)
      return {type : 'buttonContainer', buttons : ADD_BUTTON}
    else if (node.children?.length > 2)
      return {type : 'buttonContainer', buttons : BOTH_BUTTON}

  #### special: require functions to process blocks based on context/position in AST ####

  # need to skip the block that defines a class if there are class modifiers for the class
  # (will not detect a class with no modifiers otherwise)
  'class_definition' : (node) ->
    if (node.parent?)
      if (node.parent.type is 'type_declaration') and (node.parent.children?.length > 1)
        return 'skip'
      else if (node.parent.type is 'type_declaration') and (node.parent.children?.length == 1)
        return 'block'
    else
      return 'skip'

  # need to process class variable/method declarations differently if they have or do not have
  # member modifiers. I don't know why exactly it must be done this way, but this configuration is the only
  # way that I was able to get method member modifiers working alongside variables/methods that don't
  # have method modifiers
  'class_member_declaration' : (node) ->
    if (node.children?.length == 1)
      return 'skip'
    else
      return 'block'

  'typed_member_declaration' : (node) ->
    if (node.parent?.parent?.children?.length > 1)
      return 'skip'
    else
      return 'block'

  'simple_embedded_statement' : (node) ->
    if (node.parent?.type is 'if_body')
      return 'skip'
    else if (node.children[0]?.type is 'FOR') or
            (node.children[0]?.type is 'WHILE')
      return 'block'
    else if (node.children[0]?.type is 'expression')
      method_node = node.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]
      if (method_node.children[method_node.children.length-1]?.type is 'method_invocation')
        params_list_node = method_node.children[method_node.children.length-1]
        if (params_list_node.children?.length == 2)
          return {type : 'block', buttons : ADD_BUTTON}
        else
          return {type : 'block', buttons : BOTH_BUTTON}
      else
          return 'block'
    else if (node.children[0]?.type is 'RETURN')
      return 'block'
    else if (node.children[0]?.type is 'CHECKED')
      return 'block'
    else if (node.children[0]?.type is 'UNCHECKED')
      return 'block'
    else
      if (node.children[node.children?.length-2]?.type is 'ELSE')
        return {type : 'block', buttons : BOTH_BUTTON_VERT}
      else
        return {type : 'block', buttons : ADD_BUTTON_VERT}

  'primary_expression' : (node) ->
    if (node.children[node.children.length-1]?.type is 'method_invocation') or
       (node.children[1]?.type is 'member_access') or
       (node.children[1]?.type is 'bracket_expression') or
       (node.children[1]?.type is 'OP_INC') or # ++ operator -> for some reason this is what droplet says a '++' is
       (node.children[1]?.type is 'OP_DEC') # -- operator -> for some reason this is what droplet says a '--' is
      return 'skip'
    else
      return 'block'
}

# Used to color nodes
# See view.coffee for a list of colors
COLOR_RULES = {
  'using_directive' : 'using',
  'namespace_declaration' : 'namespace',

  'type_declaration' : 'type',
  'class_definition' : 'type',

  'parameter_array' : 'variable',
  'arg_declaration' : 'variable',

  'expression' : 'expression',
  'assignment' : 'expression',
  'non_assignment_expression' : 'expression',
  'lambda_expression' : 'expression',
  'query_expression' : 'expression',
  'conditional_expression' : 'expression',
  'null_coalescing_expression' : 'expression',
  'conditional_or_expression' : 'expression',
  'conditional_and_expression' : 'expression',
  'inclusive_or_expression' : 'expression',
  'exclusive_or_expression' : 'expression',
  'and_expression' : 'expression',
  'equality_expression' : 'expression',
  'relational_expression' : 'expression',
  'shift_expression' : 'expression',
  'additive_expression' : 'expression',
  'multiplicative_expression' : 'expression',
  'unary_expression' : 'expression',
  'primary_expression' : 'expression',
  'primary_expression_start' : 'expression',
}

# defines categories for different colors, for better reusability
COLOR_DEFAULTS = {
  'using' : 'purple'
  'namespace' : 'green'
  'type' : 'lightblue'
  'variable' : 'yellow'
  'expression' : 'deeporange'
  'method' : 'indigo'
  'functionCall' : 'pink'
  'comment' : 'grey'
  'conditional' : 'lightgreen'
  'loop' : 'cyan'
  'funcPointer' : 'amber'
}

# still not exactly sure what this section does, or what the helper does
SHAPE_RULES = {
  'initializer' : helper.BLOCK_ONLY,

  'expression' : helper.VALUE_ONLY,
  'assignment' : helper.VALUE_ONLY,
  'non_assignment_expression' : helper.VALUE_ONLY,
  'lambda_expression' : helper.VALUE_ONLY,
  'query_expression' : helper.VALUE_ONLY,
  'conditional_expression' : helper.VALUE_ONLY,
  'null_coalescing_expression' : helper.VALUE_ONLY,
  'conditional_or_expression' : helper.VALUE_ONLY,
  'conditional_and_expression' : helper.VALUE_ONLY,
  'inclusive_or_expression' : helper.VALUE_ONLY,
  'exclusive_or_expression' : helper.VALUE_ONLY,
  'and_expression' : helper.VALUE_ONLY,
  'equality_expression' : helper.VALUE_ONLY,
  'relational_expression' : helper.VALUE_ONLY,
  'shift_expression' : helper.VALUE_ONLY,
  'additive_expression' : helper.VALUE_ONLY,
  'multiplicative_expression' : helper.VALUE_ONLY,
  'unary_expression' : helper.VALUE_ONLY,
  'primary_expression' : helper.VALUE_ONLY,
  'primary_expression_start' : helper.VALUE_ONLY,
}

# defines what string one should put in an empty socket when going
# from blocks to text (these can be any string, it seems)
# also allows any of the below nodes with these strings to be transformed
# into empty sockets when going from text to blocks (I think)
EMPTY_STRINGS = {
  'IDENTIFIER' : '_',
  'INTEGER_LITERAL' : '_',
  'HEX_INTEGER_LITERAL' : '_',
  'REAL_LITERAL' : '_',
  'CHARACTER_LITERAL' : '_',
  'NULL' : '_',
  'REGULAR_STRING' : '_',
  'VERBATIUM_STRING' : '_',
  'TRUE' : '_',
  'FALSE' : '_',
  'arg_declaration' : '_',
}

# defines an empty character that is created when a block is dragged out of a socket
empty = '_'

emptyIndent = ''

ADD_PARENS = (leading, trailing, node, context) ->
  leading '(' + leading()
  trailing trailing() + ')'

ADD_SEMICOLON = (leading, trailing, node, context) ->
  trailing trailing() + ';'

REMOVE_SEMICOLON = (leading, trailing, node, context) ->
  trailing trailing().replace /\s*;\s*$/, ''

# helps control what can and cannot go into a socket?
PAREN_RULES = {
#  'primary_expression': {
#    'expression': ADD_PARENS
#  },
#  'primary_expression': {
#    'literal': ADD_SEMICOLON
#  }
#  'postfixExpression': {
#    'specialMethodCall': REMOVE_SEMICOLON
#  }
}

SHAPE_CALLBACK = {

}

# defines any nodes that are to be turned into different kinds of dropdown menus;
# the choices for those dropdowns are defined by the items to the left of the semicolon
# these are used only if you aren't using the SHOULD_SOCKET function it seems?
DROPDOWNS = {

}

MODIFIERS = [
  'public',
  'private',
  'protected',
  'internal',
]

CLASS_MODIFIERS = MODIFIERS.concat([
  'abstract',
  'static',
  'partial',
  'sealed',
])

MEMBER_MODIFIERS = MODIFIERS.concat([
  'virtual',
  'abstract',
  'sealed',
])

SIMPLE_TYPES = [
  'sbyte',
  'byte',
  'short',
  'ushort',
  'int',
  'uint',
  'long',
  'ulong',
  'char',
  'float',
  'double',
  'decimal',
  'bool',
]

RETURN_TYPES = SIMPLE_TYPES.concat ([
  'void',
])

# defines behavior for adding a locked socket + dropdown menu for class modifiers
# NOTE: any node/token that can/should be turned into a dropdown must be defined as a socket,
# like in the "rules" section
SHOULD_SOCKET = (opts, node) ->
  if(node.type in ['PUBLIC', 'PRIVATE', 'PROTECTED', 'INTERNAL', 'ABSTRACT', 'STATIC', 'PARTIAL', 'SEALED', 'VIRTUAL'])
    if (node.parent?.type is 'using_directive') # skip the static keyword for static using directives
      return 'skip'
    else if (node.parent?.type is 'class_definition')
      return {
        type : 'locked',
        dropdown : CLASS_MODIFIERS
      }
    else if (node.parent?.type is 'all_member_modifier')
      return {
        type : 'locked',
        dropdown : MEMBER_MODIFIERS
      }

  # adds a locked socket for variable type specifiers (for simple types)
  else if(node.type in ['SBYTE', 'BYTE', 'SHORT', 'USHORT', 'INT', 'UINT', 'LONG', 'ULONG', 'CHAR', 'FLOAT', 'DOUBLE', 'DECIMAL', 'BOOL', 'VOID'])
    if (node.parent?.parent?.parent?.parent?.parent?.parent?.children[1]?.type is 'method_declaration') or
        (node.parent?.parent?.parent?.parent?.children[1]?.type is 'method_declaration') or
        (node.parent?.children[1]?.type is 'method_declaration')
      return {
        type : 'locked',
        dropdown : RETURN_TYPES
      }
    else
      return {
        type : 'locked',
        dropdown : SIMPLE_TYPES
      }

  # return true by default (don't know why we do this)
  return true

# defines behavior for what happens if we click a button in a block (like for
# clicking the arrow buttons in a variable assignment block)
handleButton = (str, type, block) ->
  blockType = block.nodeContext?.type ? block.parseContext

  if (type is 'add-button')
    if (blockType is 'field_declaration')
      newStr = str.slice(0, str.length-1) + ", _ = _;"

      return newStr

    else if (blockType is 'formal_parameter_list')
      newStr = str + ", int param1"

      return newStr

    else if (blockType is 'local_variable_declaration')
      newStr = str + ", _ = _"

      return newStr

    else if (blockType is 'simple_embedded_statement')
      if (str.substring(0, 2) != 'if') # method invocation
        if (str.substring(str.length-3, str.length-1) == "()")
          newStr = str.substring(0, str.length-2) + "_);"

          return newStr
        else
          newStr = str.substring(0, str.length-2) + ", _);"

          return newStr

      else # if statements
        indents = []

        block.traverseOneLevel (child) ->
          if child.type is 'indent'
            indents.push child
        indents = indents[-3...]

        if indents.length is 1
          return str + ' else {\n  \n}\n'

        else if indents.length is 2
          {string: prefix} = model.stringThrough(
            block.start,
            ((token) -> token is indents[0].end),
            false
          )

          suffix = str[prefix.length + 1...]

          return prefix + '\n} else if (a == b) {\n    \n' + suffix

        else if indents.length is 3
          {string: prefix} = model.stringThrough(
            block.start,
            ((token) -> token is indents[1].end),
            false
          )

          suffix = str[prefix.length + 1...]

          return prefix + '\n} else if (a == b) {\n    \n' + suffix

  else if (type is 'subtract-button')
    if (blockType is 'field_declaration')
      newStr = str.slice(0, str.lastIndexOf(",")) + ";"

      return newStr

    else if (blockType is 'formal_parameter_list')
      lastCommaIndex = str.lastIndexOf(",")
      newStr = str.substring(0, lastCommaIndex)

      return newStr

    else if (blockType is 'local_variable_declaration')
      newStr = str.slice(0, str.lastIndexOf(","))

      return newStr

    else if (blockType is 'simple_embedded_statement')

      if (str.substring(0, 2) != 'if') # method invocation
        lastCommaIndex = str.lastIndexOf(",")

        if (lastCommaIndex != -1)
          newStr = str.substring(0, lastCommaIndex) + ");"
        else
          openParenIndex = str.lastIndexOf("(")
          newStr = str.substring(0, openParenIndex + 1) + ");"

        return newStr

      else # if statements
        indents = []
        block.traverseOneLevel (child) ->
          if child.type is 'indent'
            indents.push child
        indents = indents[-3...]

        if indents.length is 1
          return str

        else
          {string: prefix} = model.stringThrough(
            block.start,
            ((token) -> token is indents[0].end),
            false
          )

          {string: suffix} = model.stringThrough(
            block.end,
            ((token) -> token is indents[1].end),
            true
          )

          return prefix + suffix
  return str

# allows us to color the same node in different ways given different
# contexts for it in the AST
COLOR_CALLBACK = (opts, node) ->
  if (node.type is 'class_member_declaration')
    if (node.children[node.children.length-1]?.children[0]?.children[1]?.type is 'field_declaration')
      return 'variable'
    else if (node.children[node.children?.length-1]?.children[0]?.children[1]?.type is 'method_declaration') or
            (node.children[node.children?.length-1]?.children[1]?.type is 'method_declaration')
      return 'method'
    else if (node.children[1]?.children[0]?.type is 'delegate_definition')
      return 'funcPointer'
    else return 'comment'

  else if (node.type is 'typed_member_declaration')
    if (node.children[1]?.type is 'field_declaration')
      return 'variable'
    else if (node.children[1]?.type is 'method_declaration')
      return 'method'
    else return 'comment'

  else if (node.type is 'statement')
    if (node.children[0]?.type is 'local_variable_declaration')
      return 'variable'
    else
      return 'comment'

  else if (node.type is 'simple_embedded_statement')
    if (node.children[0]?.type is 'IF')
      return 'conditional'
    if (node.children[0]?.children[0]?.type is 'assignment')
      return 'variable'
    else if (node.children[0]?.type is 'expression')
    # Forgive me, God
      method_node = node.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]?.children[0]
      if (method_node.children[method_node.children.length-1]?.type is 'method_invocation') or
         (method_node.children[1]?.type is 'member_access')
        return 'functionCall'
      else
        return 'expression'
    else if (node.children[0]?.type is 'FOR') or
            (node.children[0]?.type is 'WHILE')
      return 'loop'
    else if (node.children[0]?.type is 'RETURN')
      return 'variable'
    else if (node.children[0]?.type is 'CHECKED')
      return 'expression'
    else if (node.children[0]?.type is 'UNCHECKED')
      return 'expression'
    else
      return 'comment'


  return null

# Acceptance mapping is [drag][drop]
ACCEPT_MAPPING =
{
# TODO: fill out for all constructs when (most of) everything can be turned into blocks
}

getType = (block) ->
  if !block?
    return null
  if block.parseContext?
    return block.parseContext
  if block.nodeContext?
    return block.nodeContext.type
  if block.type == "indent" && block.parentParseContext? && block.parentParseContext != null
    return block.parentParseContext
  return block.type

# defines behavior for what happens if we try to drop a block
handleAcceptance = (block, context, pred, next) ->
  dragType = getType(block)
  dropType = getType(context)
  nextType = getType(next)
  predType = getType(pred)

  if !dragType? || dragType == null
    console.log "Could not extract block type: " + helper.noCycleStringify(block)
    return null

  # Special case for imports; they can only occur at the beginning of the document or after other imports.
  # We must also prevent other items from going in front of imports.
  if dragType == 'importDeclaration' && !(predType == 'importDeclaration' || predType == 'document')
    return helper.FORBID
 # TODO: ptobably gotta modify the types for these ^^^ and these vvv
  if nextType == 'importDeclaration' && dragType != 'importDeclaration'
    return helper.FORBID

  # Deal with indents
  if dropType == 'intent'
    dropType = predType

  if !dropType? || dropType == null
    console.log "Could not extract context type: " + helper.noCycleStringify(context)
    return null


  if ACCEPT_MAPPING[dragType]? && ACCEPT_MAPPING[dragType][dropType]?
  #      console.log ("Drag/Drop " + dragType + "/" + dropType + ": " + ACCEPT_MAPPING[dragType][dropType])
    return ACCEPT_MAPPING[dragType][dropType]

  console.log "Uncaught block/context [" + dragType + "/" + dropType + "] with pred/next [" + predType + "/" + nextType + "]:\n" + helper.noCycleStringify(block) + "\n" + helper.noCycleStringify(context) + "\n" + helper.noCycleStringify(pred) + "\n" +  helper.noCycleStringify(next)
  return null

config = {
  RULES,
  COLOR_DEFAULTS,
  COLOR_RULES,
  SHAPE_RULES,
  SHAPE_CALLBACK,
  EMPTY_STRINGS,
  COLOR_DEFAULTS,
  DROPDOWNS,
  EMPTY_STRINGS,
  empty,
  emptyIndent,
  PAREN_RULES,
  SHOULD_SOCKET,
  handleButton,
  COLOR_CALLBACK,
  handleAcceptance,
}

module.exports = parser.wrapParser antlrHelper.createANTLRParser 'CSharp', config