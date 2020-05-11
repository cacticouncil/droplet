# Droplet config editor
window.expressionContext = {
  prefix: 'a = '
}

window.dropletConfig = ace.edit 'droplet-config'
dropletConfig.setTheme 'ace/theme/chrome'
dropletConfig.getSession().setMode 'ace/mode/coffee'

# dropletConfig.setValue localStorage.getItem('config') ? '''
dropletConfig.setValue '''
  ({
    mode: 'coffeescript',
    modeOptions: {
      functions: {
                    },
        },
    palette: [
      {
        name: 'Variables',
        color: 'orange',
        blocks: [
          { block: 'x = 0'},
        ]
      },

      {
        name: 'Operators',
        color: 'yellow',
        blocks: [
          { block: 'a + b' },
          { block: 'a - b' },
          { block: 'a * b' },
          { block: 'a / b' },
          { block: 'a % b' },
          { block: 'a++' },
          { block: 'a--' },

          { block: 'a = b'},
          { block: 'a += b'},
          { block: 'a -= b'},
          { block: 'a *= b'},
          { block: 'a /= b'},
          { block: 'a %= b'},


          { block: 'a == b' },
          { block: 'a != b' },
          { block: 'a > b' },
          { block: 'a >= b' },
          { block: 'a < b' },
          { block: 'a <= b' },

          { block: 'a && b' },
          { block: 'a || b' },
          { block: '!a' },

          { block: 'a & b' },
          { block: 'a | b' },
          { block: 'a ^ b' },
          { block: '~a' },
          { block: 'a << b' },
          { block: 'a >> b' },
          { block: '(a > b) ? 1 : 2'},

          { block: 'typeof a'},

          { block: 'true' },
          { block: 'false' }
        ]
      },

      {
        name: 'Controls',
        color: 'green',
        blocks: [
          { block: 'if a == b\n\ta += 1'},

          { block: 'while a == b\n\ta += 1'},
          { block: 'for i in [0...count]\n\ta += b'},
        ]
      },

      {
        name: 'Functions',
        color: 'blue',
        blocks: [
          { block: 'FunctionName = (args) -> a = \'potato\''},
          { block: 'FunctionName(args)'},


        ]
      },

      {
        name: 'Classes',
        color: 'purple',
        blocks: [
         { block: 'class ClassName\n\tconstructor: (arg)->\n\@arg = arg'},
         { block: 'classInstant = new ClassName()'},
         { block: 'class ClassName extends ParentClass'},
        ]
      }
    ]
  })
'''

# Droplet itself
createEditor = (options) ->
  $('#droplet-editor').html ''
  editor = new droplet.Editor $('#droplet-editor')[0], options

  editor.setEditorState localStorage.getItem('blocks') is 'yes'
  editor.aceEditor.getSession().setUseWrapMode true

  # Initialize to starting text
  #editor.setValue localStorage.getItem('text') ? ''

  editor.on 'change', ->
    localStorage.setItem 'text', editor.getValue()

  window.editor = editor

createEditor eval dropletConfig.getValue()

$('#toggle').on 'click', ->
  editor.toggleBlocks()
  localStorage.setItem 'blocks', (if editor.currentlyUsingBlocks then 'yes' else 'no')

# Stuff for testing convenience
$('#update').on 'click', ->
  localStorage.setItem 'config', dropletConfig.getValue()
  createEditor eval dropletConfig.getValue()

configCurrentlyOut = localStorage.getItem('configOut') is 'yes'

updateConfigDrawerState = ->
  if configCurrentlyOut
    $('#left-panel').css 'left', '0px'
    $('#right-panel').css 'left', '525px'
  else
    $('#left-panel').css 'left', '-500px'
    $('#right-panel').css 'left', '25px'

  editor.resize()

  localStorage.setItem 'configOut', (if configCurrentlyOut then 'yes' else 'no')

$('#close').on 'click', ->
  configCurrentlyOut = not configCurrentlyOut
  updateConfigDrawerState()

updateConfigDrawerState()