csharp =
  'mode': 'csharp'
  'palette': [
    {
      'name': 'Templates'
      'color': 'blue'
      'blocks': [
        {
          'block': 'using System;'
          'context': 'using_directives'
        }
        {
          'block': 'using System.IO;'
          'context': 'using_directives'
        }
        {
          'block': 'namespace namespaceName {\n\t\n}'
          'context': 'namespace_declaration'
        }
        {
          'block': 'int i = 0;'
          'context': 'common_member_declaration'
        }
        {
          'block': 'public static void main();'
          'expansion': 'public static void main(string[] args) {\n\t\n}'
          'context': 'class_member_declaration'
        }
        {
          'id': 'comment',
          'block': '//Comment\n',
        },
      ]
    }
    {
      'name': 'Classes'
      'color': 'purple'
      'blocks': [
        {
          'block': 'public class className {\n\t\n}'
          'context': 'type_declaration'
        }
        {
          'block': 'int methodName(int param1) {\n\t\n}'
          'context': 'common_member_declaration'
        }
        {
          'block': 'className.methodName(param1);'
          'context': 'simple_embedded_statement'
        }
      ]
    }
    {
      'name': 'Selection'
      'color': 'orange'
      'blocks': [
        {
          'block': 'if (x == y){\n\t\n}'
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'if_else',
          'block': 'if (x == y){\n\t\n}\nelse{\n    \n}',
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'if_elseif_else',
          'block': 'if (x == y){\n\t\n}\nelse if (x > y)\n{\n\t\n}\nelse\n{\n\t\n}',
          'context': 'simple_embedded_statement'
        }    
      ]
    }
    {
      'name': 'Loops'
      'color': 'deeporange'
      'blocks': [
        {
          'block': 'for(int i = 0; i < x; i++);'
          'expansion': 'for(int i = 0; i < x; i++) {\n\t\n}'
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'while',
          'block': 'while(0 == 0){\n\t\n}',
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'do_while',
          'block': 'do{\n\t\n}\nwhile(0 == 0);',
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'break',
          'block': 'break;',
          'context': 'simple_embedded_statement'
        }
        {
          'id': 'continue',
          'block': 'continue;',
          'context': 'simple_embedded_statement'
        } 
      ]
    }
    {
      'name': 'Logic'
      'color': 'cyan'
      'blocks': [
        {
          'block' : 'x & y'
          'context' : 'expression'
        }
        {
          'block' : 'x ^ y'
          'context' : 'expression'
        }
        {
          'block' : 'x | y'
          'context' : 'expression'
        }
        {
          'block' : 'x < y'
          'context' : 'expression'
        }
        {
          'block' : 'x <= y'
          'context' : 'expression'
        }
        {
          'block' : 'x > y'
          'context' : 'expression'
        }
        {
          'block' : 'x >= y'
          'context' : 'expression'
        }
        {
          'block' : 'x == y'
          'context' : 'expression'
        }
        {
          'block' : 'x && y'
          'context' : 'expression'
        }
        {
          'block' : 'x || y'
          'context' : 'expression'
        }
        {
          'block' : '!x'
          'context' : 'expression'
        }
        {
          'block': '(x > y ? x : y)'
          'context': 'expression'
        }
      ]
    }
    {
      'name':'Arithmetic'
      'color':'teal'
      'blocks':[
        {
          'block':'x + y'
          'context':'expression'
        }
        {
          'block':'x - y'
          'context':'expression'
        }
        {
          'block':'x * y'
          'context':'expression'
        }
        {
          'block':'x / y'
          'context':'expression'
        }
        {
          'block':'x % y'
          'context':'expression'
        }
        {
          'block':'x++;'
          'context':'simple_embedded_statement'
        }
        {
          'block' : 'x--;'
          'context' : 'simple_embedded_statement'
        }
        {
          'block' : '++x'
          'context' : 'expression'
        }
        {
          'block' : '--x'
          'context' : 'expression'
        }
      ]
    }
  ]
sessions = {}
editor = new (droplet.Editor)(document.getElementById('editor'), csharp)
document.getElementById('toggle').addEventListener 'click', ->
  editor.toggleBlocks()
  return
